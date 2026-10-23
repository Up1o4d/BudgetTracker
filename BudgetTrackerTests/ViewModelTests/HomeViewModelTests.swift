@testable import BudgetTracker
import Foundation
import Testing

struct HomeViewModelTests {
    private func makeSUT() -> HomeViewModel {
        HomeViewModel(
            transactionsProvider: InMemoryTransactionsProvider(),
            categoriesProvider: InMemoryCategoriesProvider(),
            appSettings: InMemoryAppSettings()
        )
    }

    @Test
    func selectedMonthHeaderText_includesDaysLeftSuffixForCurrentMonth() {
        let sut = makeSUT()
        let expected = "\(MonthYear.current().displayName) · \(MonthYear.current().daysRemaining())d left"
        #expect(sut.selectedMonthHeaderText == expected)
    }

    @Test
    func selectedMonthHeaderText_omitsSuffixForNonCurrentMonth() {
        let sut = makeSUT()
        sut.selectPreviousMonth()
        #expect(sut.selectedMonthHeaderText == sut.selectedMonthYear.displayName)
    }
}
