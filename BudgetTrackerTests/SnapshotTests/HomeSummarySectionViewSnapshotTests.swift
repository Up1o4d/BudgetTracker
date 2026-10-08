@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct HomeSummarySectionViewSnapshotTests {
    private static let categorySpending: [CategorySpending] = [
        .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
        .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
        .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
    ]

    // MARK: - Spending up vs. last month

    @Test
    func homeSummarySectionView_spendingUp_light() {
        let view = HomeSummarySectionView(
            categorySpending: Self.categorySpending,
            totalCurrentMonthSpending: 1050,
            budget: 2300,
            currency: "USD",
            percentageOfBudgetSpent: 1050.0 / 2300.0,
            lastMonthSpendingDiffPercent: 0.12,
            previousMonthName: "September"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeSummarySectionView_spendingUp_dark() {
        let view = HomeSummarySectionView(
            categorySpending: Self.categorySpending,
            totalCurrentMonthSpending: 1050,
            budget: 2300,
            currency: "USD",
            percentageOfBudgetSpent: 1050.0 / 2300.0,
            lastMonthSpendingDiffPercent: 0.12,
            previousMonthName: "September"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Spending down vs. last month, over budget

    @Test
    func homeSummarySectionView_spendingDownOverBudget_light() {
        let view = HomeSummarySectionView(
            categorySpending: Self.categorySpending,
            totalCurrentMonthSpending: 2600,
            budget: 2300,
            currency: "USD",
            percentageOfBudgetSpent: 2600.0 / 2300.0,
            lastMonthSpendingDiffPercent: -0.08,
            previousMonthName: "September"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeSummarySectionView_spendingDownOverBudget_dark() {
        let view = HomeSummarySectionView(
            categorySpending: Self.categorySpending,
            totalCurrentMonthSpending: 2600,
            budget: 2300,
            currency: "USD",
            percentageOfBudgetSpent: 2600.0 / 2300.0,
            lastMonthSpendingDiffPercent: -0.08,
            previousMonthName: "September"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - No prior month data

    @Test
    func homeSummarySectionView_noPreviousMonthData_light() {
        let view = HomeSummarySectionView(
            categorySpending: Self.categorySpending,
            totalCurrentMonthSpending: 1050,
            budget: 2300,
            currency: "USD",
            percentageOfBudgetSpent: 1050.0 / 2300.0,
            lastMonthSpendingDiffPercent: nil,
            previousMonthName: "September"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeSummarySectionView_noPreviousMonthData_dark() {
        let view = HomeSummarySectionView(
            categorySpending: Self.categorySpending,
            totalCurrentMonthSpending: 1050,
            budget: 2300,
            currency: "USD",
            percentageOfBudgetSpent: 1050.0 / 2300.0,
            lastMonthSpendingDiffPercent: nil,
            previousMonthName: "September"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
