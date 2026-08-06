@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct FlowLayoutSnapshotTests {
    // MARK: - Single row (fits without wrapping)

    @Test
    func flowLayout_singleRow_light() {
        let view = FlowLayout {
            Chip(text: "Groceries", systemImage: "cart.fill")
            Chip(text: "Dining", systemImage: "fork.knife")
        }
        .padding()
        .frame(width: 350, height: 60)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func flowLayout_singleRow_dark() {
        let view = FlowLayout {
            Chip(text: "Groceries", systemImage: "cart.fill")
            Chip(text: "Dining", systemImage: "fork.knife")
        }
        .padding()
        .frame(width: 350, height: 60)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Wraps to multiple rows

    @Test
    func flowLayout_wrapsToMultipleRows_light() {
        let view = FlowLayout {
            ForEach(Category.all) { category in
                Chip(text: category.name, systemImage: category.symbolName, iconColor: Color(hex: category.colorHex))
            }
        }
        .padding()
        .frame(width: 320, height: 160)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func flowLayout_wrapsToMultipleRows_dark() {
        let view = FlowLayout {
            ForEach(Category.all) { category in
                Chip(text: category.name, systemImage: category.symbolName, iconColor: Color(hex: category.colorHex))
            }
        }
        .padding()
        .frame(width: 320, height: 160)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Oversized item

    @Test
    func flowLayout_oversizedItem_light() {
        let view = FlowLayout {
            Chip(text: "Groceries", systemImage: "cart.fill")
            Chip(text: "A very long category name that overflows the row", systemImage: "text.alignleft")
            Chip(text: "Dining", systemImage: "fork.knife")
        }
        .padding()
        .frame(width: 320, height: 160)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func flowLayout_oversizedItem_dark() {
        let view = FlowLayout {
            Chip(text: "Groceries", systemImage: "cart.fill")
            Chip(text: "A very long category name that overflows the row", systemImage: "text.alignleft")
            Chip(text: "Dining", systemImage: "fork.knife")
        }
        .padding()
        .frame(width: 320, height: 160)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
