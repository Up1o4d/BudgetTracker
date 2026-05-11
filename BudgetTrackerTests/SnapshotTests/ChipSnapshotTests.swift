@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct ChipSnapshotTests {
    @Test
    func groceries_light() {
        let category = Category.groceries
        let view = Chip(systemImage: category.symbolName, text: category.name, iconColor: Color(hex: category.colorHex))
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func groceries_dark() {
        let category = Category.groceries
        let view = Chip(systemImage: category.symbolName, text: category.name, iconColor: Color(hex: category.colorHex))
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
