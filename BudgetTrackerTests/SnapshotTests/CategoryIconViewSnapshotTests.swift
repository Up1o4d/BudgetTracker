@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct CategoryIconViewSnapshotTests {
    @Test
    func categoryIconView_groceries_light() {
        let view = CategoryIconView(category: .groceries)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func categoryIconView_groceries_dark() {
        let view = CategoryIconView(category: .groceries)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Unknown category

    @Test
    func categoryIconView_unknown_light() {
        let view = CategoryIconView(category: .unknown)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func categoryIconView_unknown_dark() {
        let view = CategoryIconView(category: .unknown)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
