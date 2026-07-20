import Foundation

protocol TransactionsProviderProtocol: Sendable {
    /// Sole content channel. Many emissions, never finishes. Silent on creation — the stream
    /// yields nothing until the first `fetchTransactions(uuid:filter:)` sets a filter and pushes
    /// content down it. Keeps the existing `DataState` contract: implementations that can't refresh
    /// synchronously (e.g. a REST-backed provider) may yield an interim `.loading` state before the
    /// settled `.idle`/`.error` state, and every emission carries the last known good `data` — a
    /// `.loading` (refresh in flight) or `.error` (refresh failed) state re-attaches the previously
    /// emitted data rather than blanking it. Consumers can therefore assign each emission verbatim.
    ///
    /// The returned `UUID` is a handle the caller MUST thread back into every
    /// `fetchTransactions(uuid:filter:)` call for this stream. This tuple-return is easy to misuse
    /// (nothing binds the handle to the stream at the type level, and forgetting to thread it back
    /// means fetches silently target no stream) — flagged here; not redesigned.
    func transactionsStream() async -> (AsyncStream<DataState<Transaction>>, UUID)

    /// Filter setter + awaitable refresh. Writes `filter` into `uuid`'s registry entry (so
    /// subsequent write-driven re-emits stay correctly scoped), runs the query, and yields the
    /// settled `DataState` down `uuid`'s stream. The return is IGNORABLE for content — content
    /// always arrives via the stream; the return exists only to give pull-to-refresh an awaitable.
    func fetchTransactions(uuid: UUID, filter: TransactionFilter) async -> Result<[Transaction], Error>

    func addTransactions(_ newTransactions: [Transaction]) async throws
}
