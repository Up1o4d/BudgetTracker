import Foundation

@Observable
final class ActivityViewModel {
    private let transactionsProvider: any TransactionsProviderProtocol
    private let categoriesProvider: any CategoriesProviderProtocol

    private(set) var transactionsState: DataState<Transaction> = .initial
    private(set) var categoriesState: DataState<Category> = .initial

    private(set) var filterCategoryIds: Set<String> = []

    var viewLoadingState: LoadingState {
        .merged(transactionsState.viewLoadingState, categoriesState.viewLoadingState)
    }

    var transactionsByDate: [Date: [Transaction]] {
        Dictionary(grouping: transactionsState.data, by: { Calendar.current.startOfDay(for: $0.date) })
    }

    private var transactionFilter: TransactionFilter {
        TransactionFilter(categoryIds: filterCategoryIds.isEmpty ? nil : filterCategoryIds)
    }

    init(
        transactionsProvider: any TransactionsProviderProtocol,
        categoriesProvider: any CategoriesProviderProtocol
    ) {
        self.transactionsProvider = transactionsProvider
        self.categoriesProvider = categoriesProvider
    }

    private func loadTransactions() async {
        transactionsState = DataState(loadingState: .loading, data: transactionsState.data)
        do {
            let data = try await transactionsProvider.fetchTransactions(filter: transactionFilter)
            transactionsState = DataState(loadingState: .idle, data: data)
        } catch {
            transactionsState = DataState(loadingState: .error, data: transactionsState.data, error: error)
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
        _ = await (
            loadTransactions(),
            loadCategories()
        )
    }

    func toggleFilterCategory(_ category: Category) {
        if filterCategoryIds.contains(category.id) {
            filterCategoryIds.remove(category.id)
        } else {
            filterCategoryIds.insert(category.id)
        }
        Task { await loadTransactions() }
    }

    func resetFilterCategories() {
        filterCategoryIds.removeAll()
        Task { await loadTransactions() }
    }
}
