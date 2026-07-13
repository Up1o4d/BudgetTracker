@testable import BudgetTracker
import Foundation
import SwiftData
import Testing

/// Contract tests for `transactionsStream(filter:)`, run against every production provider
/// so the observable behavior (initial emit, one settled re-emission per write, per-stream
/// filtering) stays identical between them. Providers are free to interleave interim
/// `.loading` emissions before a settled state (`InMemoryTransactionsProvider` does, to
/// simulate a slow refetch) — tests below use `nextSettled()` wherever they want "the next
/// real result" so they stay valid regardless of how many interim states precede it.
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

    // MARK: - initial emit

    @Test(arguments: ProviderKind.allCases)
    func transactionsStream_emitsCurrentSetOnSubscribe(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        let vendor = uniqueVendor("Vendor")
        let transaction = Transaction(id: UUID().uuidString, amount: 10, vendor: vendor, categoryId: Category.groceries.id, date: .now)
        try await provider.addTransactions([transaction])

        let stream = await provider.transactionsStream(filter: TransactionFilter(vendorSubstring: vendor))
        var iterator = stream.makeAsyncIterator()
        let first = try #require(await iterator.next())

        // The very first emission on subscribe is always settled directly, for both
        // providers — only a write-triggered refresh may interleave a .loading pulse.
        #expect(first.loadingState == .idle)
        #expect(first.data == [transaction])
    }

    // MARK: - re-emit on insert

    @Test(arguments: ProviderKind.allCases)
    func addTransactions_triggersReEmitReflectingInsert(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        let vendor = uniqueVendor("Vendor")
        let filter = TransactionFilter(vendorSubstring: vendor)

        let stream = await provider.transactionsStream(filter: filter)
        var iterator = stream.makeAsyncIterator()
        let initial = try #require(await iterator.next())
        #expect(initial.data.isEmpty)

        let transaction = Transaction(id: UUID().uuidString, amount: 10, vendor: vendor, categoryId: Category.groceries.id, date: .now)
        try await provider.addTransactions([transaction])

        let updated = try #require(await iterator.nextSettled())
        #expect(updated.data == [transaction])
    }

    // MARK: - filtered re-emit

    @Test(arguments: ProviderKind.allCases)
    func addTransactions_filteredStream_onlyReflectsMatchingInsert(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        let vendor = uniqueVendor("Vendor")
        let filter = TransactionFilter(vendorSubstring: vendor)

        let stream = await provider.transactionsStream(filter: filter)
        var iterator = stream.makeAsyncIterator()
        _ = try #require(await iterator.next())

        let matching = Transaction(id: UUID().uuidString, amount: 10, vendor: vendor, categoryId: Category.groceries.id, date: .now)
        let nonMatching = Transaction(id: UUID().uuidString, amount: 20, vendor: uniqueVendor("Other"), categoryId: Category.dining.id, date: .now)
        try await provider.addTransactions([matching, nonMatching])

        let updated = try #require(await iterator.nextSettled())
        #expect(updated.data == [matching])
    }

    // MARK: - simultaneous streams

    @Test(arguments: ProviderKind.allCases)
    func addTransactions_twoSimultaneousFilteredStreams_eachGetsOwnReemission(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        let vendorA = uniqueVendor("VendorA")
        let vendorB = uniqueVendor("VendorB")

        let streamA = await provider.transactionsStream(filter: TransactionFilter(vendorSubstring: vendorA))
        let streamB = await provider.transactionsStream(filter: TransactionFilter(vendorSubstring: vendorB))
        var iteratorA = streamA.makeAsyncIterator()
        var iteratorB = streamB.makeAsyncIterator()
        _ = try #require(await iteratorA.next())
        _ = try #require(await iteratorB.next())

        let txA = Transaction(id: UUID().uuidString, amount: 10, vendor: vendorA, categoryId: Category.groceries.id, date: .now)
        let txB = Transaction(id: UUID().uuidString, amount: 20, vendor: vendorB, categoryId: Category.dining.id, date: .now)
        try await provider.addTransactions([txA, txB])

        let updatedA = try #require(await iteratorA.nextSettled())
        let updatedB = try #require(await iteratorB.nextSettled())

        #expect(updatedA.data == [txA])
        #expect(updatedB.data == [txB])
    }

    // MARK: - one settled update per write, not per row

    @Test(arguments: ProviderKind.allCases)
    func addTransactions_emitsExactlyOneSettledUpdateRegardlessOfRowCount(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        let vendor = uniqueVendor("Vendor")
        let filter = TransactionFilter(vendorSubstring: vendor)

        let stream = await provider.transactionsStream(filter: filter)
        let box = StreamIteratorBox(stream)
        _ = try #require(await box.next())

        let transactions = (0 ..< 3).map { i in
            Transaction(id: UUID().uuidString, amount: Decimal(i), vendor: vendor, categoryId: Category.groceries.id, date: .now)
        }
        try await provider.addTransactions(transactions)

        let firstReemission = try #require(await box.nextSettled())
        #expect(Set(firstReemission.data.map(\.id)) == Set(transactions.map(\.id)))

        // Nothing else should follow — not another settled update, and (once past any
        // interim .loading pulses already consumed by nextSettled) not another emission
        // of any kind — until the next write.
        let secondReemission = await box.nextOrTimeout()
        #expect(secondReemission == nil)
    }

    // MARK: - InMemory: interim loading emission carries data forward

    @Test
    func inMemoryProvider_addTransactions_loadingEmissionCarriesPreviouslyKnownData() async throws {
        let provider = InMemoryTransactionsProvider()
        let vendor = uniqueVendor("Vendor")
        let filter = TransactionFilter(vendorSubstring: vendor)

        // Seed a prior snapshot before subscribing so the interim .loading pulse has
        // something non-empty to carry forward.
        let existing = Transaction(id: UUID().uuidString, amount: 10, vendor: vendor, categoryId: Category.groceries.id, date: .now)
        try await provider.addTransactions([existing])

        let stream = await provider.transactionsStream(filter: filter)
        var iterator = stream.makeAsyncIterator()
        let initial = try #require(await iterator.next())
        #expect(initial.loadingState == .idle)
        #expect(initial.data == [existing])

        let added = Transaction(id: UUID().uuidString, amount: 20, vendor: vendor, categoryId: Category.groceries.id, date: .now)
        try await provider.addTransactions([added])

        // The interim .loading pulse re-attaches the last-known data instead of blanking it.
        let loadingState = try #require(await iterator.next())
        #expect(loadingState.loadingState == .loading)
        #expect(loadingState.data == [existing])

        let settledState = try #require(await iterator.next())
        #expect(settledState.loadingState == .idle)
        #expect(Set(settledState.data.map(\.id)) == Set([existing.id, added.id]))
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
