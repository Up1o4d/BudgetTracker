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
        do {
            transactions = try await transactionsProvider.fetchTransactions()
        } catch {
            loadingState = .error
            return
        }
        loadingState = transactions.isEmpty ? .empty : .idle
    }
}
