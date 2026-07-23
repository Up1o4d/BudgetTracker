@testable import BudgetTracker
import Foundation
import Testing

/// Unit tests for `DataStreamRegistry` in isolation — driven with `Int` elements to prove it is
/// genuinely element-agnostic and to keep the focus on the registry's own invariants rather than
/// any provider's query semantics: silent-until-first-fetch, interim `.loading` that carries the
/// last-known data forward, settled data replacing it, `.error` never blanking a loaded list,
/// per-uuid generation gating of stale in-flight fetches, write-driven `refetchAll` using each
/// stream's stored query, and per-uuid isolation.
struct DataStreamRegistryTests {
    private enum TestError: Error { case boom }

    // MARK: - silent channel

    @Test
    func makeStream_beforeAnyFetch_emitsNothing() async {
        let registry = DataStreamRegistry<Int>()
        let (stream, _) = await registry.makeStream()
        let recorder = StreamRecorder(stream)

        // A freshly made stream is a silent channel: no emission until the first fetch binds a query.
        let arrived = await recorder.nextOrTimeout()
        #expect(arrived == nil)
    }

    // MARK: - fetch emission sequence

    @Test
    func fetch_emitsInterimLoadingThenSettledIdle() async throws {
        let registry = DataStreamRegistry<Int>()
        let (stream, uuid) = await registry.makeStream()
        let recorder = StreamRecorder(stream)

        await registry.fetch(uuid: uuid) { [1, 2, 3] }

        let interim = try #require(await recorder.next())
        #expect(interim.loadingState == .loading)
        #expect(interim.data == []) // nothing loaded yet, so the interim carries an empty list

        let settled = try #require(await recorder.next())
        #expect(settled.loadingState == .idle)
        #expect(settled.data == [1, 2, 3])
    }

    @Test
    func fetch_returnsSettledStateToCaller() async {
        let registry = DataStreamRegistry<Int>()
        let (_, uuid) = await registry.makeStream()

        let settled = await registry.fetch(uuid: uuid) { [42] }

        #expect(settled.loadingState == .idle)
        #expect(settled.data == [42])
    }

    // MARK: - last-known data carried forward

    @Test
    func fetch_secondFetch_interimLoadingCarriesPreviousDataForward() async throws {
        let registry = DataStreamRegistry<Int>()
        let (stream, uuid) = await registry.makeStream()
        let recorder = StreamRecorder(stream)

        await registry.fetch(uuid: uuid) { [1] }
        _ = try #require(await recorder.nextSettled()) // drain the first settled state

        await registry.fetch(uuid: uuid) { [1, 2] }

        // The second fetch's interim `.loading` carries the previously loaded data, never blanking it.
        let interim = try #require(await recorder.next())
        #expect(interim.loadingState == .loading)
        #expect(interim.data == [1])

        let settled = try #require(await recorder.next())
        #expect(settled.loadingState == .idle)
        #expect(settled.data == [1, 2])
    }

    @Test
    func fetch_queryThrows_emitsErrorCarryingLastDataForward() async throws {
        let registry = DataStreamRegistry<Int>()
        let (stream, uuid) = await registry.makeStream()
        let recorder = StreamRecorder(stream)

        await registry.fetch(uuid: uuid) { [1, 2] }
        _ = try #require(await recorder.nextSettled())

        let settled = await registry.fetch(uuid: uuid) { throw TestError.boom }

        // A failed refresh surfaces `.error` but keeps the last successfully loaded list visible.
        #expect(settled.loadingState == .error)
        #expect(settled.data == [1, 2])
        #expect(settled.error != nil)

        let emitted = try #require(await recorder.nextSettled())
        #expect(emitted.loadingState == .error)
        #expect(emitted.data == [1, 2])
    }

    @Test
    func fetch_firstFetchThrows_emitsErrorWithEmptyData() async {
        let registry = DataStreamRegistry<Int>()
        let (_, uuid) = await registry.makeStream()

        let settled = await registry.fetch(uuid: uuid) { throw TestError.boom }

        #expect(settled.loadingState == .error)
        #expect(settled.data == []) // nothing loaded yet, so there is nothing to carry forward
        #expect(settled.error != nil)
    }

    // MARK: - per-uuid isolation

    @Test
    func fetch_onOneStream_doesNotEmitOnAnother() async throws {
        let registry = DataStreamRegistry<Int>()
        let (streamA, uuidA) = await registry.makeStream()
        let (streamB, _) = await registry.makeStream()
        let recorderA = StreamRecorder(streamA)
        let recorderB = StreamRecorder(streamB)

        await registry.fetch(uuid: uuidA) { [1] }

        let settledA = try #require(await recorderA.nextSettled())
        #expect(settledA.data == [1])

        // B was never fetched, so its channel stays silent.
        let arrivedB = await recorderB.nextOrTimeout()
        #expect(arrivedB == nil)
    }

    // MARK: - write-driven re-emit

    @Test
    func refetchAll_reRunsEachStreamStoredQuery() async throws {
        let registry = DataStreamRegistry<Int>()
        let source = IntSource([1, 2, 3, 4])

        let (streamEvens, uuidEvens) = await registry.makeStream()
        let (streamOdds, uuidOdds) = await registry.makeStream()
        let recorderEvens = StreamRecorder(streamEvens)
        let recorderOdds = StreamRecorder(streamOdds)

        await registry.fetch(uuid: uuidEvens) { await source.values.filter { $0 % 2 == 0 } }
        await registry.fetch(uuid: uuidOdds) { await source.values.filter { $0 % 2 != 0 } }
        #expect(try #require(await recorderEvens.nextSettled()).data == [2, 4])
        #expect(try #require(await recorderOdds.nextSettled()).data == [1, 3])

        await source.set([1, 2, 3, 4, 5, 6])
        await registry.refetchAll()

        // Each stream re-runs its OWN stored query against the new source, staying correctly scoped.
        #expect(try #require(await recorderEvens.nextSettled()).data == [2, 4, 6])
        #expect(try #require(await recorderOdds.nextSettled()).data == [1, 3, 5])
    }

    @Test
    func refetchAll_skipsNeverFetchedStreams() async throws {
        let registry = DataStreamRegistry<Int>()
        let (fetchedStream, fetchedUuid) = await registry.makeStream()
        let (silentStream, _) = await registry.makeStream()
        let recorderFetched = StreamRecorder(fetchedStream)
        let recorderSilent = StreamRecorder(silentStream)

        await registry.fetch(uuid: fetchedUuid) { [1] }
        _ = try #require(await recorderFetched.nextSettled())

        await registry.refetchAll()

        // The fetched stream re-emits; the never-fetched one has no stored query, so it stays silent.
        #expect(try #require(await recorderFetched.nextSettled()).data == [1])
        let arrivedSilent = await recorderSilent.nextOrTimeout()
        #expect(arrivedSilent == nil)
    }

    // MARK: - generation gating

    @Test
    func fetch_staleInFlightFetchIsSupersededPerUuid() async throws {
        let registry = DataStreamRegistry<Int>()
        let (stream, uuid) = await registry.makeStream()
        let recorder = StreamRecorder(stream)

        let staleStarted = AsyncEvent()
        let releaseStale = AsyncEvent()

        // Park a fetch inside its query so a newer fetch on the same uuid can claim a higher
        // generation while the first is still in flight.
        let staleFetch = Task {
            await registry.fetch(uuid: uuid) {
                await staleStarted.signal()
                await releaseStale.wait()
                return [1]
            }
        }
        await staleStarted.wait() // the stale query is now parked; the actor is free

        // The newer fetch bumps the generation in its synchronous prologue and settles immediately.
        await registry.fetch(uuid: uuid) { [2] }

        await releaseStale.signal() // let the stale fetch finish — it must NOT yield its result
        _ = await staleFetch.value

        // Only the newer fetch's settled data reaches the stream.
        let settled = try #require(await recorder.nextSettled())
        #expect(settled.data == [2])

        // The superseded fetch produced no further emission.
        let extra = await recorder.nextOrTimeout()
        #expect(extra == nil)
    }
}

// MARK: - Helpers

/// Backing store for `refetchAll` tests: an isolated, mutable source the stored queries read so a
/// re-emit observes writes made between fetches.
private actor IntSource {
    var values: [Int]
    init(_ values: [Int]) { self.values = values }
    func set(_ newValues: [Int]) { values = newValues }
}

/// A latch that can be awaited before it is signalled and resumes any/all waiters once signalled —
/// used to deterministically order concurrent fetches without sleeps.
private actor AsyncEvent {
    private var isSignalled = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func signal() {
        isSignalled = true
        for waiter in waiters { waiter.resume() }
        waiters.removeAll()
    }

    func wait() async {
        if isSignalled { return }
        await withCheckedContinuation { waiters.append($0) }
    }
}

/// Drives an `AsyncStream` iterator from a reference type so a "did anything else arrive" check can
/// race the next value against a timeout without fighting `Iterator`'s value-semantics/mutating
/// requirements. Generic over the element so it works for any `DataStreamRegistry<Element>`.
private nonisolated final class StreamRecorder<Element: Sendable>: @unchecked Sendable {
    private var iterator: AsyncStream<DataState<Element>>.Iterator

    init(_ stream: AsyncStream<DataState<Element>>) {
        iterator = stream.makeAsyncIterator()
    }

    func next() async -> DataState<Element>? {
        await iterator.next()
    }

    /// Skips interim `.loading` emissions and returns the next settled (`.idle`/`.error`) state.
    func nextSettled() async -> DataState<Element>? {
        while let state = await next() {
            if state.loadingState != .loading { return state }
        }
        return nil
    }

    /// `.none` if nothing arrived before `timeout`; `.some(value)` (possibly `.some(nil)`) otherwise.
    func nextOrTimeout(_ timeout: Duration = .milliseconds(200)) async -> DataState<Element>?? {
        await withTaskGroup(of: Outcome<Element>.self) { group in
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

    private enum Outcome<T: Sendable>: Sendable {
        case value(DataState<T>?)
        case timeout
    }
}
