@testable import BudgetTracker
import Foundation
import Testing

struct MonthCategorySpendingViewModelTests {
    let transactionsProvider: MockTransactionsProvider
    let month: MonthYear
    let sut: MonthCategorySpendingViewModel

    init() {
        transactionsProvider = MockTransactionsProvider()
        month = .current()
        sut = MonthCategorySpendingViewModel(
            month: month,
            category: .groceries,
            transactionsProvider: transactionsProvider,
            appSettings: InMemoryAppSettings()
        )
    }

    private var dateInMonth: Date { month.monthDateRange.lowerBound }
    private var dateInPreviousMonth: Date { month.previousMonth.monthDateRange.lowerBound }

    // MARK: - Initial state

    @Test
    func initialState() {
        #expect(sut.viewLoadingState == .loading)
        #expect(sut.transactions.isEmpty)
        #expect(sut.totalAmount == 0)
    }

    // MARK: - loadData() happy path

    @Test
    func loadData_setsIdleState() async {
        await sut.loadData()
        await waitUntil { sut.viewLoadingState == .idle }
        #expect(sut.viewLoadingState == .idle)
    }

    @Test
    func loadData_fetchesWithCategoryAndMonthFilter() async throws {
        await sut.loadData()

        let filter = try #require(transactionsProvider.lastFilter)
        #expect(filter.categoryIds == [Category.groceries.id])
        #expect(filter.dateRange == month.monthDateRange)
    }

    @Test
    func loadData_includesOnlyMatchingTransactions() async {
        let matching = Transaction(id: "1", amount: 10, vendor: "A", categoryId: Category.groceries.id, date: dateInMonth)
        transactionsProvider.stubbedTransactions = [
            matching,
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: Category.dining.id, date: dateInMonth),
            Transaction(id: "3", amount: 30, vendor: "C", categoryId: Category.groceries.id, date: dateInPreviousMonth),
        ]

        await sut.loadData()
        await waitUntil { sut.transactions == [matching] }
        #expect(sut.transactions == [matching])
    }

    @Test
    func loadData_sortsNewestFirstAndSumsTotal() async {
        let older = Transaction(id: "1", amount: 10, vendor: "A", categoryId: Category.groceries.id, date: dateInMonth)
        let newer = Transaction(id: "2", amount: 15.5, vendor: "B", categoryId: Category.groceries.id, date: dateInMonth.addingTimeInterval(3600))
        transactionsProvider.stubbedTransactions = [older, newer]

        await sut.loadData()
        await waitUntil { sut.transactions.count == 2 }
        #expect(sut.transactions == [newer, older])
        #expect(sut.totalAmount == Decimal(string: "25.5"))
    }

    // MARK: - loadData() error path

    @Test
    func loadData_setsErrorState() async {
        transactionsProvider.stubbedError = NSError(domain: "test", code: 1)

        await sut.loadData()
        await waitUntil { sut.viewLoadingState == .error }
        #expect(sut.viewLoadingState == .error)
    }

    // MARK: - deinit

    @Test
    func deinit_terminatesTransactionsStream() async {
        var viewModel: MonthCategorySpendingViewModel? = MonthCategorySpendingViewModel(
            month: month,
            category: .groceries,
            transactionsProvider: transactionsProvider,
            appSettings: InMemoryAppSettings()
        )
        await viewModel?.loadData()
        #expect(transactionsProvider.activeStreamCount == 1)

        viewModel = nil

        await waitUntil { transactionsProvider.activeStreamCount == 0 }
        #expect(transactionsProvider.activeStreamCount == 0)
    }

    // MARK: - Live updates

    @Test
    func addTransactions_matchingTransactionAppearsWithoutRefetch() async throws {
        await sut.loadData()
        await waitUntil { sut.viewLoadingState == .idle }

        let added = Transaction(id: "1", amount: 10, vendor: "A", categoryId: Category.groceries.id, date: dateInMonth)
        try await transactionsProvider.addTransactions([added])

        await waitUntil { sut.transactions == [added] }
        #expect(sut.transactions == [added])
        #expect(transactionsProvider.fetchTransactionsCallCount == 1)
    }

    @Test
    func addTransactions_nonMatchingTransactionIsExcluded() async throws {
        let existing = Transaction(id: "1", amount: 10, vendor: "A", categoryId: Category.groceries.id, date: dateInMonth)
        transactionsProvider.stubbedTransactions = [existing]
        await sut.loadData()
        await waitUntil { sut.transactions == [existing] }

        let otherCategory = Transaction(id: "2", amount: 20, vendor: "B", categoryId: Category.dining.id, date: dateInMonth)
        let matching = Transaction(id: "3", amount: 30, vendor: "C", categoryId: Category.groceries.id, date: dateInMonth.addingTimeInterval(60))
        try await transactionsProvider.addTransactions([otherCategory, matching])

        await waitUntil { sut.transactions.count == 2 }
        #expect(sut.transactions == [matching, existing])
    }
}
