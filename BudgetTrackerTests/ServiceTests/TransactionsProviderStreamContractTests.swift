@testable import BudgetTracker
import Foundation
import SwiftData
import Testing

/// Contract tests for the `transactionsStream()` / `fetchTransactions(uuid:filter:)` pair, run
/// against every production provider so the observable behavior stays identical between them:
/// the stream is a silent channel until the first `fetchTransactions` sets a filter and pushes
/// content; every subsequent write re-emits per stream using that stream's *stored* filter; and
/// a stale in-flight fetch is superseded per uuid. Providers are free to interleave interim
/// `.loading` emissions before a settled state (`InMemoryTransactionsProvider` does, to simulate a
/// slow refetch) — tests use `nextSettled()` wherever they want "the next real result" so they
/// stay valid regardless of how many interim states precede it.
struct TransactionsProviderStreamContractTests {
    enum ProviderKind: String, CaseIterable {
        case swiftData
        case inMemory
    }

    private func makeProvider(_ kind: ProviderKind) throws -> any TransactionsProviderProtocol {
        switch kind {
        case .swiftData:
            let container = try ModelContainer(
                for: StoredTransaction.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            return SwiftDataTransactionsProvider(modelContainer: container)
        case .inMemory:
            return InMemoryTransactionsProvider()
        }
    }

    private func uniqueVendor(_ label: String) -> String {
        "\(label)-\(UUID().uuidString)"
    }

    // MARK: - write-driven re-emit uses the stored filter

    @Test(arguments: ProviderKind.allCases)
    func fetchTransactions_thenWrite_reEmitsStoredFilterScopeIncludingNewRow(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        let vendor = uniqueVendor("Vendor")
        // The category component proves scoping; the unique-vendor component isolates from the
        // in-memory provider's seed data (which contains many groceries rows).
        let filter = TransactionFilter(categoryIds: [Category.groceries.id], vendorSubstring: vendor)

        let grocery1 = Transaction(id: UUID().uuidString, amount: 10, vendor: vendor, categoryId: Category.groceries.id, date: .now)
        let dining1 = Transaction(id: UUID().uuidString, amount: 20, vendor: vendor, categoryId: Category.dining.id, date: .now)
        try await provider.addTransactions([grocery1, dining1])

        let (stream, uuid) = await provider.transactionsStream()
        var iterator = stream.makeAsyncIterator()

        // fetch is the filter setter and the first content trigger.
        _ = await provider.fetchTransactions(uuid: uuid, filter: filter)
        let initial = try #require(await iterator.nextSettled())
        #expect(initial.data == [grocery1]) // dining excluded by category, seed excluded by vendor

        let grocery2 = Transaction(id: UUID().uuidString, amount: 30, vendor: vendor, categoryId: Category.groceries.id, date: .now)
        let dining2 = Transaction(id: UUID().uuidString, amount: 40, vendor: vendor, categoryId: Category.dining.id, date: .now)
        try await provider.addTransactions([grocery2, dining2])

        // The write-driven re-emit re-runs uuid's STORED filter: groceries-scoped, including the
        // newly written groceries row, and still excluding the newly written dining row.
        let reEmit = try #require(await iterator.nextSettled())
        #expect(Set(reEmit.data.map(\.id)) == Set([grocery1.id, grocery2.id]))
        #expect(!reEmit.data.contains { $0.categoryId == Category.dining.id })
    }

    // MARK: - simultaneous streams

    @Test(arguments: ProviderKind.allCases)
    func addTransactions_twoSimultaneousStreams_eachReEmitsOwnScope(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        let vendorA = uniqueVendor("VendorA")
        let vendorB = uniqueVendor("VendorB")

        let (streamA, uuidA) = await provider.transactionsStream()
        let (streamB, uuidB) = await provider.transactionsStream()
        var iteratorA = streamA.makeAsyncIterator()
        var iteratorB = streamB.makeAsyncIterator()

        _ = await provider.fetchTransactions(uuid: uuidA, filter: TransactionFilter(vendorSubstring: vendorA))
        _ = await provider.fetchTransactions(uuid: uuidB, filter: TransactionFilter(vendorSubstring: vendorB))
        _ = try #require(await iteratorA.nextSettled())
        _ = try #require(await iteratorB.nextSettled())

        let txA = Transaction(id: UUID().uuidString, amount: 10, vendor: vendorA, categoryId: Category.groceries.id, date: .now)
        let txB = Transaction(id: UUID().uuidString, amount: 20, vendor: vendorB, categoryId: Category.dining.id, date: .now)
        try await provider.addTransactions([txA, txB])

        let updatedA = try #require(await iteratorA.nextSettled())
        let updatedB = try #require(await iteratorB.nextSettled())

        #expect(updatedA.data == [txA])
        #expect(updatedB.data == [txB])
    }

    // MARK: - stale in-flight fetch superseded per uuid

    @Test
    func inMemory_fetchTransactions_staleInFlightFetchIsSupersededPerUuid() async throws {
        let provider = InMemoryTransactionsProvider()
        let vendorA = uniqueVendor("VendorA")
        let vendorB = uniqueVendor("VendorB")
        let txA = Transaction(id: UUID().uuidString, amount: 10, vendor: vendorA, categoryId: Category.groceries.id, date: .now)
        let txB = Transaction(id: UUID().uuidString, amount: 20, vendor: vendorB, categoryId: Category.dining.id, date: .now)
        try await provider.addTransactions([txA, txB])

        let (stream, uuid) = await provider.transactionsStream()
        let box = StreamIteratorBox(stream)

        // Start the vendorA fetch, let it enter the actor and park in its simulated-latency sleep,
        // then start the vendorB fetch on the SAME uuid. vendorB claims the newer generation, so
        // only vendorB may reach the stream — the now-stale vendorA fetch must not yield after it.
        let staleFetch = Task {
            await provider.fetchTransactions(uuid: uuid, filter: TransactionFilter(vendorSubstring: vendorA))
        }
        try await Task.sleep(for: .milliseconds(100))
        _ = await provider.fetchTransactions(uuid: uuid, filter: TransactionFilter(vendorSubstring: vendorB))
        _ = await staleFetch.value

        let settled = try #require(await box.nextSettled())
        #expect(settled.data == [txB])

        // Nothing else arrives — the superseded vendorA fetch never yields.
        let extra = await box.nextOrTimeout()
        #expect(extra == nil)
    }
}

private nonisolated extension AsyncStream<DataState<Transaction>>.Iterator {
    /// Skips any interim `.loading` emissions and returns the next settled (`.idle`/`.error`) state.
    mutating func nextSettled() async -> DataState<Transaction>? {
        while let state = await next() {
            if state.loadingState != .loading { return state }
        }
        return nil
    }
}

/// Drives an `AsyncStream` iterator from a reference type so a "did nothing else arrive"
/// check can race the next value against a timeout without fighting `Iterator`'s
/// value-semantics/mutating-method requirements.
private nonisolated final class StreamIteratorBox: @unchecked Sendable {
    private var iterator: AsyncStream<DataState<Transaction>>.Iterator

    init(_ stream: AsyncStream<DataState<Transaction>>) {
        iterator = stream.makeAsyncIterator()
    }

    func next() async -> DataState<Transaction>? {
        await iterator.next()
    }

    func nextSettled() async -> DataState<Transaction>? {
        while let state = await next() {
            if state.loadingState != .loading { return state }
        }
        return nil
    }

    func nextOrTimeout(_ timeout: Duration = .milliseconds(200)) async -> DataState<Transaction>?? {
        await withTaskGroup(of: Outcome.self) { group in
            group.addTask { .value(await self.next()) }
            group.addTask {
                try? await Task.sleep(for: timeout)
                return .timeout
            }
            let outcome = await group.next()!
            group.cancelAll()
            switch outcome {
            case .value(let value): return .some(value)
            case .timeout: return .none
            }
        }
    }

    private enum Outcome {
        case value(DataState<Transaction>?)
        case timeout
    }
}
