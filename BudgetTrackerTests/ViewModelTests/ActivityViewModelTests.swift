@testable import BudgetTracker
import Foundation
import Testing

struct ActivityViewModelTests {
    // MARK: - Initial state

    @Test func initialState() {
        let vm = ActivityViewModel(transactionsProvider: MockTransactionsProvider())
        #expect(vm.loadingState == .initial)
        #expect(vm.transactions.isEmpty)
    }

    // MARK: - loadTransactions() happy path

    @Test func loadTransactions_setsIdleStateWhenTransactionsNonEmpty() async {
        let provider = MockTransactionsProvider()
        provider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", category: .groceries, date: .now),
        ]
        let vm = ActivityViewModel(transactionsProvider: provider)
        await vm.loadTransactions()
        #expect(vm.loadingState == .idle)
    }

    @Test func loadTransactions_setsEmptyStateWhenNoTransactions() async {
        let vm = ActivityViewModel(transactionsProvider: MockTransactionsProvider())
        await vm.loadTransactions()
        #expect(vm.loadingState == .empty)
    }

    @Test func loadTransactions_populatesTransactions() async {
        let provider = MockTransactionsProvider()
        let transactions = [
            Transaction(id: "1", amount: 10, vendor: "A", category: .groceries, date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", category: .dining, date: .now),
        ]
        provider.stubbedTransactions = transactions
        let vm = ActivityViewModel(transactionsProvider: provider)
        await vm.loadTransactions()
        #expect(vm.transactions == transactions)
    }

    @Test func loadTransactions_callsProviderOnce() async {
        let provider = MockTransactionsProvider()
        let vm = ActivityViewModel(transactionsProvider: provider)
        await vm.loadTransactions()
        #expect(provider.fetchTransactionsCallCount == 1)
    }

    // MARK: - loadTransactions() error path

    @Test func loadTransactions_setsErrorState() async {
        let provider = MockTransactionsProvider()
        provider.stubbedError = NSError(domain: "test", code: 0)
        let vm = ActivityViewModel(transactionsProvider: provider)
        await vm.loadTransactions()
        #expect(vm.loadingState == .error)
    }

    // MARK: - transactionsByDate

    @Test func transactionsByDate_groupsByCalendarDay() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        let provider = MockTransactionsProvider()
        provider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", category: .groceries, date: today),
            Transaction(id: "2", amount: 20, vendor: "B", category: .dining, date: today),
            Transaction(id: "3", amount: 30, vendor: "C", category: .rent, date: yesterday),
        ]
        let vm = ActivityViewModel(transactionsProvider: provider)
        await vm.loadTransactions()

        #expect(vm.transactionsByDate[today]?.count == 2)
        #expect(vm.transactionsByDate[yesterday]?.count == 1)
    }
}
