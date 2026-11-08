@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct HomeCategorySpendingRowViewSnapshotTests {
    private static let groceries = CategorySpending(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40)
    private static let dining = CategorySpending(category: .dining, totalAmount: 180, percentageOfTotal: 0.17, roundedPercentage: 17)

    // MARK: - Max category

    @Test
    func homeCategorySpendingRowView_maxCategory_light() {
        let view = HomeCategorySpendingRowView(spending: Self.groceries, currency: "USD", maxCategorySpending: Self.groceries)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeCategorySpendingRowView_maxCategory_dark() {
        let view = HomeCategorySpendingRowView(spending: Self.groceries, currency: "USD", maxCategorySpending: Self.groceries)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Smaller category

    @Test
    func homeCategorySpendingRowView_smallerCategory_light() {
        let view = HomeCategorySpendingRowView(spending: Self.dining, currency: "USD", maxCategorySpending: Self.groceries)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeCategorySpendingRowView_smallerCategory_dark() {
        let view = HomeCategorySpendingRowView(spending: Self.dining, currency: "USD", maxCategorySpending: Self.groceries)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - No max category

    @Test
    func homeCategorySpendingRowView_noMaxCategory_light() {
        let view = HomeCategorySpendingRowView(spending: Self.groceries, currency: "USD", maxCategorySpending: nil)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeCategorySpendingRowView_noMaxCategory_dark() {
        let view = HomeCategorySpendingRowView(spending: Self.groceries, currency: "USD", maxCategorySpending: nil)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Redacted

    @Test
    func homeCategorySpendingRowView_redacted_light() {
        let view = HomeCategorySpendingRowView(spending: Self.dining, currency: "USD", maxCategorySpending: Self.groceries)
            .redacted(reason: .placeholder)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeCategorySpendingRowView_redacted_dark() {
        let view = HomeCategorySpendingRowView(spending: Self.dining, currency: "USD", maxCategorySpending: Self.groceries)
            .redacted(reason: .placeholder)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
