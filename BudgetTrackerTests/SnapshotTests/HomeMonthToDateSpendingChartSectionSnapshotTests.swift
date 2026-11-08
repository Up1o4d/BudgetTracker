@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct HomeMonthToDateSpendingChartSectionSnapshotTests {
    private static let selectedMonth = MonthYear.current(from: Date(timeIntervalSince1970: 1_792_000_000))
    private static let dailySpendingSums: [Decimal] = [
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        12.99, 34.55, 99.12, 34.55, 289.20, 599.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 0.00, 499.10, 10.0,
    ]

    // MARK: - Loaded

    @Test
    func homeMonthToDateSpendingChartSection_loaded_light() {
        let view = HomeMonthToDateSpendingChartSection(
            selectedMonth: Self.selectedMonth,
            currentMonthDailySpendingSums: Self.dailySpendingSums,
            currency: "USD"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeMonthToDateSpendingChartSection_loaded_dark() {
        let view = HomeMonthToDateSpendingChartSection(
            selectedMonth: Self.selectedMonth,
            currentMonthDailySpendingSums: Self.dailySpendingSums,
            currency: "USD"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Empty

    @Test
    func homeMonthToDateSpendingChartSection_empty_light() {
        let view = HomeMonthToDateSpendingChartSection(
            selectedMonth: Self.selectedMonth,
            currentMonthDailySpendingSums: [],
            currency: "USD"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeMonthToDateSpendingChartSection_empty_dark() {
        let view = HomeMonthToDateSpendingChartSection(
            selectedMonth: Self.selectedMonth,
            currentMonthDailySpendingSums: [],
            currency: "USD"
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Redacted

    @Test
    func homeMonthToDateSpendingChartSection_redacted_light() {
        let view = HomeMonthToDateSpendingChartSection(
            selectedMonth: Self.selectedMonth,
            currentMonthDailySpendingSums: Self.dailySpendingSums,
            currency: "USD"
        )
        .redacted(reason: .placeholder)
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeMonthToDateSpendingChartSection_redacted_dark() {
        let view = HomeMonthToDateSpendingChartSection(
            selectedMonth: Self.selectedMonth,
            currentMonthDailySpendingSums: Self.dailySpendingSums,
            currency: "USD"
        )
        .redacted(reason: .placeholder)
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
