@testable import BudgetTracker
import Foundation
import Testing

struct ActivityViewModelTests {
    let provider: MockTransactionsProvider
    let sut: ActivityViewModel

    init() {
        provider = MockTransactionsProvider()
        sut = ActivityViewModel(transactionsProvider: provider)
    }

    // MARK: - Initial state

    @Test
    func initialState() {
        #expect(sut.loadingState == .initial)
        #expect(sut.transactions.isEmpty)
    }

    // MARK: - loadTransactions() happy path

    @Test
    func loadTransactions_setsIdleStateWhenTransactionsNonEmpty() async {
        provider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        await sut.loadTransactions()
        #expect(sut.loadingState == .idle)
    }

    @Test
    func loadTransactions_setsEmptyStateWhenNoTransactions() async {
        await sut.loadTransactions()
        #expect(sut.loadingState == .empty)
    }

    @Test
    func loadTransactions_populatesTransactions() async {
        let transactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        provider.stubbedTransactions = transactions
        await sut.loadTransactions()
        #expect(sut.transactions == transactions)
    }

    @Test
    func loadTransactions_callsProviderOnce() async {
        await sut.loadTransactions()
        #expect(provider.fetchTransactionsCallCount == 1)
    }

    // MARK: - loadTransactions() error path

    @Test
    func loadTransactions_setsErrorState() async {
        provider.stubbedError = NSError(domain: "test", code: 0)
        await sut.loadTransactions()
        #expect(sut.loadingState == .error)
    }

    // MARK: - transactionsByDate

    @Test
    func transactionsByDate_groupsByCalendarDay() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        provider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: today),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: today),
            Transaction(id: "3", amount: 30, vendor: "C", categoryId: "rent", date: yesterday),
        ]
        await sut.loadTransactions()

        #expect(sut.transactionsByDate[today]?.count == 2)
        #expect(sut.transactionsByDate[yesterday]?.count == 1)
    }
}
