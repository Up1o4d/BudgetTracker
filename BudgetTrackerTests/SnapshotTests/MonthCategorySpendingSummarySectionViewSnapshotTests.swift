@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct MonthCategorySpendingSummarySectionViewSnapshotTests {
    private static let month = MonthYear.current(from: Date(timeIntervalSince1970: 1_792_000_000))
    private static let dailySpendingSums: [Decimal] = [
        0.0, 12.99, 0.0, 34.55, 0.0, 0.0, 99.12,
        0.0, 0.0, 34.55, 0.0, 28.20, 0.0, 9.11,
        0.0, 12.99, 0.0, 0.0, 41.30, 0.0, 0.0,
        19.75, 0.0, 0.0, 64.10, 0.0, 0.0, 22.40,
    ]

    private static func loadedView() -> MonthCategorySpendingSummarySectionView {
        MonthCategorySpendingSummarySectionView(
            category: .groceries,
            month: month,
            totalAmount: dailySpendingSums.reduce(Decimal.zero, +),
            transactionCount: 12,
            dailySpendingSums: dailySpendingSums,
            currency: "USD"
        )
    }

    private static func emptyView() -> MonthCategorySpendingSummarySectionView {
        MonthCategorySpendingSummarySectionView(
            category: .groceries,
            month: month,
            totalAmount: 0,
            transactionCount: 0,
            dailySpendingSums: [],
            currency: "USD"
        )
    }

    // MARK: - Loaded

    @Test
    func monthCategorySpendingSummarySectionView_loaded_light() {
        let view = Self.loadedView()
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func monthCategorySpendingSummarySectionView_loaded_dark() {
        let view = Self.loadedView()
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Empty

    @Test
    func monthCategorySpendingSummarySectionView_empty_light() {
        let view = Self.emptyView()
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func monthCategorySpendingSummarySectionView_empty_dark() {
        let view = Self.emptyView()
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Redacted

    @Test
    func monthCategorySpendingSummarySectionView_redacted_light() {
        let view = Self.loadedView()
            .redacted(reason: .placeholder)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func monthCategorySpendingSummarySectionView_redacted_dark() {
        let view = Self.loadedView()
            .redacted(reason: .placeholder)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
