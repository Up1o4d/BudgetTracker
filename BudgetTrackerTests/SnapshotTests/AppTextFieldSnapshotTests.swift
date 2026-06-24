@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct AppTextFieldSnapshotTests {
    @Test
    func appTextField_withIcon_light() {
        let view = AppTextField(iconSystemName: "magnifyingglass", placeholderText: "Lorem Ipsum", text: .constant(""))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func appTextField_withIcon_dark() {
        let view = AppTextField(iconSystemName: "magnifyingglass", placeholderText: "Lorem Ipsum", text: .constant(""))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    @Test
    func appTextField_noIcon_light() {
        let view = AppTextField(placeholderText: "Lorem Ipsum", text: .constant(""))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func appTextField_noIcon_dark() {
        let view = AppTextField(placeholderText: "Lorem Ipsum", text: .constant(""))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    @Test
    func appTextField_withInsertedText_light() {
        let view = AppTextField(placeholderText: "Lorem Ipsum", text: .constant("Inserted text"))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func appTextField_withInsertedText_dark() {
        let view = AppTextField(placeholderText: "Lorem Ipsum", text: .constant("Inserted text"))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
