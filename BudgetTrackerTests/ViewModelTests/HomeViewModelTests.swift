@testable import BudgetTracker
import Foundation
import SwiftUI
import Testing

struct HomeViewModelTests {
    let transactionsProvider: MockTransactionsProvider
    let categoriesProvider: MockCategoriesProvider
    let appSettings: InMemoryAppSettings
    let router: AppRouter
    let sut: HomeViewModel

    init() {
        transactionsProvider = MockTransactionsProvider()
        categoriesProvider = MockCategoriesProvider()
        appSettings = InMemoryAppSettings()
        router = AppRouter()
        sut = HomeViewModel(
            transactionsProvider: transactionsProvider,
            categoriesProvider: categoriesProvider,
            appSettings: appSettings,
            router: router
        )
    }

    private func expectedFetchRange(around month: MonthYear) -> ClosedRange<Date> {
        month.adding(months: -2).monthDateRange.lowerBound ... month.adding(months: 1).monthDateRange.upperBound
    }

    private func dateInside(_ month: MonthYear) -> Date {
        month.monthDateRange.lowerBound.addingTimeInterval(60 * 60)
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
            Transaction(id: "1", amount: 100, vendor: "A", categoryId: "groceries", date: dateInside(current)),
            Transaction(id: "2", amount: 50, vendor: "B", categoryId: "dining", date: dateInside(current)),
            Transaction(id: "3", amount: 100, vendor: "C", categoryId: "groceries", date: dateInside(current.previousMonth)),
        ]
        transactionsProvider.stubbedTransactions = transactions
        await sut.loadData()
        await waitUntil { sut.transactionsState.data.count == transactions.count }

        let summary = sut.summary(for: current)
        #expect(summary.totalSpending == 150)
        #expect(summary.transactionCount == 2)
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

    // MARK: - budget

    @Test
    func budget_readsFromAppSettings() {
        #expect(sut.budget == nil)

        appSettings.budget = 2300

        #expect(sut.budget == 2300)
    }

    @Test
    func budget_changeInAppSettingsNotifiesObservers() async {
        let changed = AsyncEvent()
        withObservationTracking {
            _ = sut.budget
        } onChange: {
            Task { await changed.signal() }
        }

        appSettings.budget = 1000

        await changed.wait()
        #expect(sut.budget == 1000)
    }

    // MARK: - summary(for:) budget percentage

    @Test
    func summaryPercentageOfBudgetSpent_isZeroWhenBudgetNotSet() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 100, vendor: "A", categoryId: "groceries", date: dateInside(.current())),
        ]
        await sut.loadData()
        await waitUntil { sut.transactionsState.data.count == 1 }

        #expect(sut.summary(for: .current()).percentageOfBudgetSpent == 0)
    }

    @Test
    func summaryPercentageOfBudgetSpent_isZeroWhenBudgetIsZero() async {
        appSettings.budget = 0
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 100, vendor: "A", categoryId: "groceries", date: dateInside(.current())),
        ]
        await sut.loadData()
        await waitUntil { sut.transactionsState.data.count == 1 }

        #expect(sut.summary(for: .current()).percentageOfBudgetSpent == 0)
    }

    @Test
    func summaryPercentageOfBudgetSpent_dividesSpendingByBudget() async {
        appSettings.budget = 400
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 100, vendor: "A", categoryId: "groceries", date: dateInside(.current())),
        ]
        await sut.loadData()
        await waitUntil { sut.transactionsState.data.count == 1 }

        #expect(sut.summary(for: .current()).percentageOfBudgetSpent == 0.25)
    }

    // MARK: - editBudgetTapped()

    @Test
    func editBudgetTapped_presentsEditBudgetSheet() {
        sut.editBudgetTapped()

        #expect(router.presentedSheet == .editBudget)
    }

    // MARK: - categoryTapped(_:in:)

    @Test
    func categoryTapped_pushesRouteOnHomeTab() {
        sut.categoryTapped(.groceries, in: .current())

        #expect(router.navigationPathBinding(for: .home).wrappedValue.count == 1)
        #expect(router.navigationPathBinding(for: .activity).wrappedValue.isEmpty)
    }
}
