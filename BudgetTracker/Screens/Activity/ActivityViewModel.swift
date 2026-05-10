import Foundation

@Observable
final class ActivityViewModel {
    private let transactionsProvider: any TransactionsProviderProtocol
    private let categoriesProvider: any CategoriesProviderProtocol

    private(set) var transactions: [Transaction] = []
    private(set) var categories: [Category] = []

    private(set) var loadingState: LoadingState = .initial

    var transactionsByDate: [Date: [Transaction]] {
        Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
    }

    init(
        transactionsProvider: any TransactionsProviderProtocol,
        categoriesProvider: any CategoriesProviderProtocol
    ) {
        self.transactionsProvider = transactionsProvider
        self.categoriesProvider = categoriesProvider
    }

    func loadData() async {
        loadingState = .loading
        do {
            transactions = try await transactionsProvider.fetchTransactions()
            categories = try await categoriesProvider.fetchCategories()
        } catch {
            loadingState = .error
            return
        }
        loadingState = transactions.isEmpty ? .empty : .idle
    }
}
