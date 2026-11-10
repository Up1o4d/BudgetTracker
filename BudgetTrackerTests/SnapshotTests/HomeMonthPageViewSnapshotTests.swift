@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct HomeMonthPageViewSnapshotTests {
    private static let month = MonthYear.current(from: Date(timeIntervalSince1970: 1_792_000_000))
    private static let categorySpending: [CategorySpending] = [
        .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
        .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
        .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
    ]
    private static let dailySpendingSums: [Decimal] = [400, 0, 120, 80, 0, 450]

    // MARK: - Loaded

    @Test
    func homeMonthPageView_loaded_light() {
        let view = makeView(summary: makeSummary())
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeMonthPageView_loaded_dark() {
        let view = makeView(summary: makeSummary())
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Loading

    @Test
    func homeMonthPageView_loading_light() {
        let view = makeView(summary: makeSummary(isLoading: true))
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeMonthPageView_loading_dark() {
        let view = makeView(summary: makeSummary(isLoading: true))
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Empty month

    @Test
    func homeMonthPageView_empty_light() {
        let view = makeView(summary: makeEmptySummary())
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeMonthPageView_empty_dark() {
        let view = makeView(summary: makeEmptySummary())
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    private func makeView(summary: MonthSummary) -> some View {
        HomeMonthPageView(summary: summary, budget: 2300, currency: "USD")
            .screenDefaults()
            .frame(width: 393, height: 852)
    }

    private func makeSummary(isLoading: Bool = false) -> MonthSummary {
        MonthSummary(
            month: Self.month,
            headerText: "October 2026 · 17d left",
            totalSpending: 1050,
            transactionCount: 52,
            percentageOfBudgetSpent: 1050.0 / 2300.0,
            lastMonthSpendingDiffPercent: -0.12,
            categorySpending: Self.categorySpending,
            dailySpendingSums: Self.dailySpendingSums,
            isLoading: isLoading
        )
    }

    private func makeEmptySummary() -> MonthSummary {
        MonthSummary(
            month: Self.month,
            headerText: "October 2026 · 17d left",
            totalSpending: 0,
            transactionCount: 0,
            percentageOfBudgetSpent: 0,
            lastMonthSpendingDiffPercent: nil,
            categorySpending: [],
            dailySpendingSums: [],
            isLoading: false
        )
    }
}
