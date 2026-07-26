@testable import BudgetTracker
import Foundation
import SwiftData
import Testing

/// Contract tests for `CategoriesProviderProtocol`, run against every production provider so the
/// observable behavior stays identical between them. Two halves:
/// - Upsert contract (`addCategories(_:)`): a category whose id is new appends, while one whose
///   id already exists updates that entry in place rather than duplicating it.
/// - Stream contract (`categoriesStream()` / `fetchCategories(uuid:)`): the stream is a silent
///   channel until the first `fetchCategories` pushes content; every subsequent write re-emits to
///   every registered stream; and a stale in-flight fetch is superseded per uuid. Unlike
///   transactions, `fetchCategories(uuid:)` takes no filter, so there's no per-stream scope to
///   differentiate — tests are adapted accordingly (see comments below).
struct CategoriesProviderContractTests {
    enum ProviderKind: String, CaseIterable {
        case swiftData
        case inMemory
    }

    private func makeProvider(_ kind: ProviderKind) throws -> any CategoriesProviderProtocol {
        switch kind {
        case .swiftData:
            let container = try ModelContainer(
                for: StoredCategory.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            return SwiftDataCategoriesProvider(modelContainer: container)
        case .inMemory:
            return InMemoryCategoriesProvider(categories: [])
        }
    }

    private func fetch(_ provider: any CategoriesProviderProtocol) async throws -> [BudgetTracker.Category] {
        let (stream, uuid) = await provider.categoriesStream()
        defer { withExtendedLifetime(stream) {} }
        return try await provider.fetchCategories(uuid: uuid).get()
    }

    // MARK: - addCategories(_:) — fresh id

    @Test(arguments: ProviderKind.allCases)
    func addCategories_withFreshId_appendsRatherThanReplacing(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        try await provider.addCategories([.groceries])

        try await provider.addCategories([.rent])

        let result = try await fetch(provider)
        #expect(Set(result.map(\.id)) == Set([Category.groceries.id, Category.rent.id]))
    }

    // MARK: - addCategories(_:) — existing id

    @Test(arguments: ProviderKind.allCases)
    func addCategories_withExistingId_updatesInPlaceRatherThanAppending(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        try await provider.addCategories([.groceries])

        let renamed = BudgetTracker.Category(
            id: Category.groceries.id, name: "Renamed", symbolName: "star.fill", colorHex: "#000000"
        )
        try await provider.addCategories([renamed])

        let result = try await fetch(provider)
        #expect(result == [renamed])
    }

    // MARK: - write-driven re-emit includes new category

    @Test(arguments: ProviderKind.allCases)
    func fetchCategories_thenWrite_reEmitsIncludingNewCategory(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        try await provider.addCategories([.groceries])

        let (stream, uuid) = await provider.categoriesStream()
        var iterator = stream.makeAsyncIterator()

        _ = await provider.fetchCategories(uuid: uuid)
        let initial = try #require(await iterator.nextSettled())
        #expect(Set(initial.data.map(\.id)) == Set([Category.groceries.id]))

        try await provider.addCategories([.rent])

        let reEmit = try #require(await iterator.nextSettled())
        #expect(Set(reEmit.data.map(\.id)) == Set([Category.groceries.id, Category.rent.id]))
    }

    // MARK: - simultaneous streams

    @Test(arguments: ProviderKind.allCases)
    func addCategories_twoSimultaneousStreams_bothReEmitFullList(kind: ProviderKind) async throws {
        let provider = try makeProvider(kind)
        try await provider.addCategories([.groceries])

        let (streamA, uuidA) = await provider.categoriesStream()
        let (streamB, uuidB) = await provider.categoriesStream()
        var iteratorA = streamA.makeAsyncIterator()
        var iteratorB = streamB.makeAsyncIterator()

        _ = await provider.fetchCategories(uuid: uuidA)
        _ = await provider.fetchCategories(uuid: uuidB)
        _ = try #require(await iteratorA.nextSettled())
        _ = try #require(await iteratorB.nextSettled())

        try await provider.addCategories([.rent])

        // No per-stream scope exists to differentiate (unlike transactions' filter), so this
        // proves the still-meaningful half: every registered stream — not just the one that
        // triggered the write — gets re-emitted the full updated list.
        let updatedA = try #require(await iteratorA.nextSettled())
        let updatedB = try #require(await iteratorB.nextSettled())

        #expect(Set(updatedA.data.map(\.id)) == Set([Category.groceries.id, Category.rent.id]))
        #expect(Set(updatedB.data.map(\.id)) == Set([Category.groceries.id, Category.rent.id]))
    }

    // MARK: - stale in-flight fetch superseded per uuid

    @Test
    func inMemory_fetchCategories_staleInFlightFetchIsSupersededPerUuid() async throws {
        let provider = InMemoryCategoriesProvider(categories: [.groceries])

        let (stream, uuid) = await provider.categoriesStream()
        let box = StreamIteratorBox(stream)

        // Categories has no filter to make the stale and fresh fetches content-distinguishable
        // (unlike transactions' vendorA/vendorB), so this proves the weaker but still meaningful
        // half of the contract: two concurrent fetches on the same uuid collapse into exactly one
        // settled emission, never two, regardless of which one the registry considers current.
        let staleFetch = Task {
            await provider.fetchCategories(uuid: uuid)
        }
        try await Task.sleep(for: .milliseconds(100))
        _ = await provider.fetchCategories(uuid: uuid)
        _ = await staleFetch.value

        let settled = try #require(await box.nextSettled())
        #expect(Set(settled.data.map(\.id)) == Set([Category.groceries.id]))

        // Nothing else arrives — the superseded fetch never yields.
        let extra = await box.nextOrTimeout()
        #expect(extra == nil)
    }
}

private nonisolated extension AsyncStream<DataState<BudgetTracker.Category>>.Iterator {
    /// Skips any interim `.loading` emissions and returns the next settled (`.idle`/`.error`) state.
    mutating func nextSettled() async -> DataState<BudgetTracker.Category>? {
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
    private var iterator: AsyncStream<DataState<BudgetTracker.Category>>.Iterator

    init(_ stream: AsyncStream<DataState<BudgetTracker.Category>>) {
        iterator = stream.makeAsyncIterator()
    }

    func next() async -> DataState<BudgetTracker.Category>? {
        await iterator.next()
    }

    func nextSettled() async -> DataState<BudgetTracker.Category>? {
        while let state = await next() {
            if state.loadingState != .loading { return state }
        }
        return nil
    }

    func nextOrTimeout(_ timeout: Duration = .milliseconds(200)) async -> DataState<BudgetTracker.Category>?? {
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
        case value(DataState<BudgetTracker.Category>?)
        case timeout
    }
}
