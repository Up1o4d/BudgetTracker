import Foundation

@Observable
final class ActivityViewModel {
    private let transactionsProvider: any TransactionsProviderProtocol

    private(set) var transactions: [Transaction] = []

    private(set) var loadingState: LoadingState = .initial

    var transactionsByDate: [Date: [Transaction]] {
        Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
    }

    init(transactionsProvider: any TransactionsProviderProtocol) {
        self.transactionsProvider = transactionsProvider
    }

    func loadTransactions() async {
        loadingState = .loading
        transactions = await transactionsProvider.fetchTransactions()
        loadingState = .idle
    }
}
