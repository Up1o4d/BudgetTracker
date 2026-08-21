@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct PrimaryButtonStyleSnapshotTests {
    // MARK: - Enabled

    @Test
    func primaryButtonStyle_enabled_light() {
        let view = Button("Primary Button") {}
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 200)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func primaryButtonStyle_enabled_dark() {
        let view = Button("Primary Button") {}
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 200)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Full width

    @Test
    func primaryButtonStyle_fullWidth_light() {
        let view = Button("Full Width") {}
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func primaryButtonStyle_fullWidth_dark() {
        let view = Button("Full Width") {}
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Disabled

    @Test
    func primaryButtonStyle_disabled_light() {
        let view = Button("Disabled") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
            .frame(width: 200)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func primaryButtonStyle_disabled_dark() {
        let view = Button("Disabled") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
            .frame(width: 200)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
