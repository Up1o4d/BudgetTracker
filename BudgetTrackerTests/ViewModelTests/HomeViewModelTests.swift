@testable import BudgetTracker
import Foundation
import Testing

struct HomeViewModelTests {
    let transactionsProvider: MockTransactionsProvider
    let categoriesProvider: MockCategoriesProvider
    let sut: HomeViewModel

    init() {
        transactionsProvider = MockTransactionsProvider()
        categoriesProvider = MockCategoriesProvider()
        sut = HomeViewModel(
            transactionsProvider: transactionsProvider,
            categoriesProvider: categoriesProvider,
            appSettings: InMemoryAppSettings()
        )
    }

    private func waitUntil(_ condition: () -> Bool, timeout: Duration = .seconds(2)) async {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while !condition(), ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    private func expectedFetchRange(around month: MonthYear) -> ClosedRange<Date> {
        month.adding(months: -2).monthDateRange.lowerBound ... month.adding(months: 1).monthDateRange.upperBound
    }

    // MARK: - Initial state

    @Test
    func initialState() {
        #expect(sut.selectedMonthYear == .current())
        #expect(sut.loadedMonths == nil)
        #expect(sut.summary(for: .current()).isLoading)
    }

    // MARK: - months

    @Test
    func months_endsAtCurrentMonth() {
        #expect(sut.months.last == .current())
        #expect(sut.months.count == 1201)
    }

    // MARK: - summary(for:) header text

    @Test
    func summaryHeaderText_includesDaysLeftSuffixForCurrentMonth() {
        let expected = "\(MonthYear.current().displayName) · \(MonthYear.current().daysRemaining())d left"
        #expect(sut.summary(for: .current()).headerText == expected)
    }

    @Test
    func summaryHeaderText_omitsSuffixForNonCurrentMonth() {
        let previousMonth = MonthYear.current().previousMonth
        #expect(sut.summary(for: previousMonth).headerText == previousMonth.displayName)
    }

    // MARK: - summary(for:) totals

    @Test
    func summary_computesTotalAndDiffAgainstPreviousMonth() async {
        let current = MonthYear.current()
        let transactions = [
            Transaction(id: "1", amount: 100, vendor: "A", categoryId: "groceries", date: current.monthDateRange.lowerBound),
            Transaction(id: "2", amount: 50, vendor: "B", categoryId: "dining", date: current.monthDateRange.lowerBound),
            Transaction(id: "3", amount: 100, vendor: "C", categoryId: "groceries", date: current.previousMonth.monthDateRange.lowerBound),
        ]
        transactionsProvider.stubbedTransactions = transactions
        await sut.loadData()
        await waitUntil { sut.transactionsState.data.count == transactions.count }

        let summary = sut.summary(for: current)
        #expect(summary.totalSpending == 150)
        #expect(summary.lastMonthSpendingDiffPercent == 0.5)
        #expect(summary.maxCategorySpending?.totalAmount == 100)
        #expect(summary.isLoading == false)
    }

    // MARK: - loadData() fetch window

    @Test
    func loadData_fetchesSelectedMonthWithNeighbours() async throws {
        await sut.loadData()
        let filter = try #require(transactionsProvider.lastFilter)
        #expect(filter.dateRange == expectedFetchRange(around: .current()))
        #expect(sut.loadedMonths == MonthYear.current().adding(months: -2) ... MonthYear.current().adding(months: 1))
    }

    // MARK: - selectedMonthYear changes

    @Test
    func selectingMonth_refetchesWindowAroundNewMonth() async throws {
        await sut.loadData()
        let target = MonthYear.current().adding(months: -6)

        sut.selectedMonthYear = target
        await sut.reloadTask?.value

        let filter = try #require(transactionsProvider.lastFilter)
        #expect(filter.dateRange == expectedFetchRange(around: target))
        #expect(sut.summary(for: target).isLoading == false)
        #expect(sut.summary(for: .current()).isLoading)
    }

    @Test
    func selectingSameMonth_doesNotRefetch() async {
        await sut.loadData()
        let callCount = transactionsProvider.fetchTransactionsCallCount

        sut.selectedMonthYear = .current()

        #expect(sut.reloadTask == nil)
        #expect(transactionsProvider.fetchTransactionsCallCount == callCount)
    }

    // MARK: - loadData() error path

    @Test
    func summary_staysLoadingWhenFetchFails() async {
        transactionsProvider.stubbedError = NSError(domain: "test", code: 1)
        await sut.loadData()
        #expect(sut.loadedMonths == nil)
        #expect(sut.summary(for: .current()).isLoading)
    }
}
