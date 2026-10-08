@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct PercentageBarSnapshotTests {
    // MARK: - Under 100%

    @Test
    func percentageBar_underCapacity_light() {
        let view = PercentageBar(percentage: 0.4, foregroundBarColor: Color.accentLime)
            .frame(width: 300, height: 8)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func percentageBar_underCapacity_dark() {
        let view = PercentageBar(percentage: 0.4, foregroundBarColor: Color.accentLime)
            .frame(width: 300, height: 8)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Over 100% (overflow)

    @Test
    func percentageBar_overCapacity_light() {
        let view = PercentageBar(percentage: 1.3, foregroundBarColor: Color.accentLime, height: 8.0)
            .frame(width: 300, height: 8)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func percentageBar_overCapacity_dark() {
        let view = PercentageBar(percentage: 1.3, foregroundBarColor: Color.accentLime, height: 8.0)
            .frame(width: 300, height: 8)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
