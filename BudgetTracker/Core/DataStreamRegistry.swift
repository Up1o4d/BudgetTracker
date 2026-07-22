import Foundation

/// Owns the AsyncStream registry, per-uuid generation gating, interim-loading emission, and the
/// "error/loading emissions carry last-known data forward" invariant shared by streaming providers.
/// It is filter-agnostic: a fetch is an already-bound closure, so the provider — not the registry —
/// owns any query parameters. This makes it reusable by any provider that streams `[Element]`,
/// including ones with no filter at all.
actor DataStreamRegistry<Element: Sendable> {
    /// Produces the latest data for one stream. The provider captures whatever it needs (e.g. a
    /// filter) inside. Throwing becomes an `.error` DataState that carries `lastData` forward.
    typealias Query = @Sendable () async throws -> [Element]

    private struct Subscription {
        let continuation: AsyncStream<DataState<Element>>.Continuation
        var lastData: [Element]
        var generation: Int
        var refresh: Query?   // nil until the first fetch binds this stream's query
    }

    private var registry: [UUID: Subscription] = [:]

    /// Silent channel: no emission until the first `fetch` binds a query and pushes content.
    func makeStream() -> (AsyncStream<DataState<Element>>, UUID) {
        let (stream, continuation) = AsyncStream.makeStream(of: DataState<Element>.self)
        let id = UUID()
        continuation.onTermination = { _ in Task { await self.deregister(id) } }
        registry[id] = Subscription(continuation: continuation, lastData: [],
                                    generation: 0, refresh: nil)
        return (stream, id)
    }

    /// Binds/updates this stream's query, then runs it, generation-gated per uuid. The generation
    /// bump happens synchronously in this prologue so a later fetch on the same uuid claims a newer
    /// generation and supersedes this one's settled yield if it lands first. Returns the settled
    /// state so the provider can map it to whatever its protocol wants.
    @discardableResult
    func fetch(uuid: UUID, query: @escaping Query) async -> DataState<Element> {
        registry[uuid]?.refresh = query
        registry[uuid]?.generation += 1
        let generation = registry[uuid]?.generation
        let lastData = registry[uuid]?.lastData ?? []

        // Signal .loading immediately, carrying the last-known data so the consumer never blanks
        // the list. Emitted from the prologue where this fetch is by definition the latest for
        // uuid, so it needs no generation gate — the settled yield below does.
        registry[uuid]?.continuation.yield(DataState(loadingState: .loading, data: lastData))

        let settled = await settledState(lastData: lastData, query: query)

        // Only yield if this is still the latest fetch for uuid and the stream is live.
        if let subscription = registry[uuid], subscription.generation == generation {
            registry[uuid]?.lastData = settled.data
            subscription.continuation.yield(settled)
        }
        return settled
    }

    /// Write-driven re-emit: re-run every stream that has been fetched, using its OWN stored query
    /// (which still closes over that stream's filter). Streams never fetched stay silent.
    func refetchAll() async {
        for id in registry.keys {
            guard let subscription = registry[id], let refresh = subscription.refresh else { continue }
            subscription.continuation.yield(
                DataState(loadingState: .loading, data: subscription.lastData))
            let settled = await settledState(lastData: subscription.lastData, query: refresh)
            registry[id]?.lastData = settled.data
            registry[id]?.continuation.yield(settled)
        }
    }

    /// On failure, carries `lastData` forward so an `.error` emission never blanks a previously
    /// loaded list.
    private func settledState(lastData: [Element], query: Query) async -> DataState<Element> {
        do {
            return DataState(loadingState: .idle, data: try await query())
        } catch {
            return DataState(loadingState: .error, data: lastData, error: error)
        }
    }

    private func deregister(_ id: UUID) { registry.removeValue(forKey: id) }
}
