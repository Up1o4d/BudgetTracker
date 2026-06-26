@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct ChipSnapshotTests {
    @Test
    func chip_groceries_light() {
        let category = Category.groceries
        let view = Chip(text: category.name, systemImage: category.symbolName, iconColor: Color(hex: category.colorHex))
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func chip_groceries_dark() {
        let category = Category.groceries
        let view = Chip(text: category.name, systemImage: category.symbolName, iconColor: Color(hex: category.colorHex))
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Chip without icon

    @Test
    func chip_noIcon_light() {
        let category = Category.groceries
        let view = Chip(text: category.name)
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func chip_noIcon_dark() {
        let category = Category.groceries
        let view = Chip(text: category.name)
            .frame(width: 200, height: 44)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
