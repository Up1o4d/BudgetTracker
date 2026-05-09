@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct CategoryChipSnapshotTests {
    @Test
    func groceries_light() {
        let view = CategoryChip(category: .groceries)
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func groceries_dark() {
        let view = CategoryChip(category: .groceries)
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
