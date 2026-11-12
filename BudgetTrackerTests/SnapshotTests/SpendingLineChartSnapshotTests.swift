@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct SpendingLineChartSnapshotTests {
    private static let values: [Decimal] = [
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        12.99, 34.55, 99.12, 34.55, 289.20, 599.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 0.00, 499.10, 10.0,
    ]
    private static let shortValues: [Decimal] = [12.99, 34.55, 99.12, 34.55, 289.20, 599.10, 9.11]

    // MARK: - Loaded

    @Test
    func spendingLineChart_loaded_light() {
        let view = SpendingLineChart(values: Self.values, color: .accentLime, xMax: 31)
            .frame(width: 350, height: 150)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func spendingLineChart_loaded_dark() {
        let view = SpendingLineChart(values: Self.values, color: .accentLime, xMax: 31)
            .frame(width: 350, height: 150)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Empty

    @Test
    func spendingLineChart_empty_light() {
        let view = SpendingLineChart(values: [], color: .accentLime, xMax: 31)
            .frame(width: 350, height: 150)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func spendingLineChart_empty_dark() {
        let view = SpendingLineChart(values: [], color: .accentLime, xMax: 31)
            .frame(width: 350, height: 150)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Custom xMin

    @Test
    func spendingLineChart_customXMin_light() {
        let view = SpendingLineChart(values: Self.shortValues, color: .accentLime, xMin: 10, xMax: 20)
            .frame(width: 350, height: 150)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func spendingLineChart_customXMin_dark() {
        let view = SpendingLineChart(values: Self.shortValues, color: .accentLime, xMin: 10, xMax: 20)
            .frame(width: 350, height: 150)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
