@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct HomeCategorySpendingSectionViewSnapshotTests {
    @Test
    func homeCategorySpendingSectionView_populated_light() {
        let categorySpending: [CategorySpending] = [
            .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
            .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
            .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
        ]
        let view = HomeCategorySpendingSectionView(
            categorySpending: categorySpending,
            currency: "USD",
            maxCategorySpending: categorySpending.first
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeCategorySpendingSectionView_populated_dark() {
        let categorySpending: [CategorySpending] = [
            .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
            .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
            .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
        ]
        let view = HomeCategorySpendingSectionView(
            categorySpending: categorySpending,
            currency: "USD",
            maxCategorySpending: categorySpending.first
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Single category

    @Test
    func homeCategorySpendingSectionView_singleCategory_light() {
        let categorySpending: [CategorySpending] = [
            .init(category: .groceries, totalAmount: 420, percentageOfTotal: 1.0, roundedPercentage: 100),
        ]
        let view = HomeCategorySpendingSectionView(
            categorySpending: categorySpending,
            currency: "USD",
            maxCategorySpending: categorySpending.first
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func homeCategorySpendingSectionView_singleCategory_dark() {
        let categorySpending: [CategorySpending] = [
            .init(category: .groceries, totalAmount: 420, percentageOfTotal: 1.0, roundedPercentage: 100),
        ]
        let view = HomeCategorySpendingSectionView(
            categorySpending: categorySpending,
            currency: "USD",
            maxCategorySpending: categorySpending.first
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
