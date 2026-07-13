import Foundation

@Observable
final class ActivityViewModel {
    typealias TransactionCategory = (transaction: Transaction, category: Category)

    private let transactionsProvider: any TransactionsProviderProtocol
    private let categoriesProvider: any CategoriesProviderProtocol
    private let appSettings: any AppSettingsProtocol

    private var successfullyFinishedInitialLoad: Bool = false
    private var searchTask: Task<Void, Never>?
    private var loadTransactionsTask: Task<Void, Never>?
    private var observationTask: Task<Void, Never>?

    private(set) var transactionsState: DataState<Transaction> = .init()
    private(set) var categoriesState: DataState<Category> = .init()

    private(set) var filterCategoryIds: Set<String> = []

    var searchString: String = "" {
        didSet {
            guard searchString != oldValue else { return }
            searchTask?.cancel()
            searchTask = Task {
                do {
                    try await Task.sleep(for: .milliseconds(300))
                    await loadTransactions()
                } catch {}
            }
        }
    }

    var viewLoadingState: LoadingState {
        guard !successfullyFinishedInitialLoad else { return .idle }
        return LoadingState.merged(transactionsState.loadingState, categoriesState.loadingState)
    }

    private var transactionFilter: TransactionFilter {
        TransactionFilter(
            categoryIds: filterCategoryIds.isEmpty ? nil : filterCategoryIds,
            vendorSubstring: searchString.isEmpty ? nil : searchString
        )
    }

    private var categoriesById: [String: Category] {
        Dictionary(uniqueKeysWithValues: categoriesState.data.map { ($0.id, $0) })
    }

    private var transactionCategories: [TransactionCategory] {
        return transactionsState.data.map {
            (
                transaction: $0,
                category: categoriesById[$0.categoryId] ?? Category.unknown
            )
        }
    }

    var transactionCategoriesByDate: [Date: [TransactionCategory]] {
        Dictionary(grouping: transactionCategories, by: { Calendar.current.startOfDay(for: $0.transaction.date) })
    }

    var currency: String {
        appSettings.currency
    }

    init(
        transactionsProvider: any TransactionsProviderProtocol,
        categoriesProvider: any CategoriesProviderProtocol,
        appSettings: any AppSettingsProtocol
    ) {
        self.transactionsProvider = transactionsProvider
        self.categoriesProvider = categoriesProvider
        self.appSettings = appSettings
    }

    private func loadTransactions() async {
        // Switching between filters quickly can trigger multiple requests
        // Cancel the previous subscription if it exists, so that new data doesn't arrive out of order
        loadTransactionsTask?.cancel()
        observationTask?.cancel()

        loadTransactionsTask = Task {
            // Mutate only the flag so the current data stays on screen while we resubscribe.
            transactionsState.loadingState = .loading

            let stream = await transactionsProvider.transactionsStream(filter: transactionFilter)
            guard !Task.isCancelled else { return }

            var iterator = stream.makeAsyncIterator()

            // A provider may emit interim .loading states before settling (e.g. a REST
            // provider mid-refetch) — keep applying those until we see a settled state,
            // so `loadData()`'s initial-load check isn't left waiting on a `.loading`
            // emission that already came and went. Every emission already carries the
            // last-known data, so we can assign it verbatim.
            while let state = await iterator.next() {
                guard !Task.isCancelled else { return }
                transactionsState = state
                if state.loadingState != .loading { break }
            }

            // Subsequent emissions (inserts) are refreshes, not initial loads — they're
            // consumed in the background so this task's `.value` only awaits the first
            // settled one.
            observationTask = Task {
                while let state = await iterator.next() {
                    guard !Task.isCancelled else { break }
                    transactionsState = state
                }
            }
        }
        await loadTransactionsTask?.value
    }

    private func loadCategories() async {
        categoriesState = DataState(loadingState: .loading, data: categoriesState.data)
        do {
            let data = try await categoriesProvider.fetchCategories()
            categoriesState = DataState(loadingState: .idle, data: data)
        } catch {
            categoriesState = DataState(loadingState: .error, data: categoriesState.data, error: error)
        }
    }

    func loadData() async {
        async let transactionsCall: Void = loadTransactions()
        async let categoriesCall: Void = loadCategories()
        _ = await (transactionsCall, categoriesCall)

        if viewLoadingState == .idle {
            successfullyFinishedInitialLoad = true
        }
    }

    func calculateMoneySpent(on date: Date) -> Decimal {
        guard let transactions = transactionCategoriesByDate[date] else { return 0 }
        return transactions.reduce(0) { partialResult, transactionCategory in
            partialResult + transactionCategory.transaction.amount
        }
    }

    /// Returned so tests can await completion; production callers discard it.
    @discardableResult
    func toggleFilterCategory(_ category: Category) -> Task<Void, Never> {
        if filterCategoryIds.contains(category.id) {
            filterCategoryIds.remove(category.id)
        } else {
            filterCategoryIds.insert(category.id)
        }
        return Task { await self.loadTransactions() }
    }

    @discardableResult
    func resetFilterCategories() -> Task<Void, Never> {
        filterCategoryIds.removeAll()
        return Task { await self.loadTransactions() }
    }
}
