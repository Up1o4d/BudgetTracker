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
        // Cancel the previous request if it exists, so that new data doesn't arrive out of order
        loadTransactionsTask?.cancel()
        loadTransactionsTask = Task {
            transactionsState = DataState(loadingState: .loading, data: transactionsState.data)
            do {
                let data = try await transactionsProvider.fetchTransactions(filter: transactionFilter)
                guard !Task.isCancelled else { return }
                transactionsState = DataState(loadingState: .idle, data: data)
            } catch is CancellationError {
                // Task got cancelled, shouldn't update state
                return
            } catch {
                guard !Task.isCancelled else { return }
                transactionsState = DataState(loadingState: .error, data: transactionsState.data, error: error)
            }
        }
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
