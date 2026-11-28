@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct SectionLabelSnapshotTests {
    // MARK: - Leading only

    @Test
    func sectionLabel_leadingOnly_light() {
        let view = SectionLabel(leading: "By category")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func sectionLabel_leadingOnly_dark() {
        let view = SectionLabel(leading: "By category")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Leading and trailing

    @Test
    func sectionLabel_leadingAndTrailing_light() {
        let view = SectionLabel(leading: "November 2026", trailing: "52 TXNS")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func sectionLabel_leadingAndTrailing_dark() {
        let view = SectionLabel(leading: "November 2026", trailing: "52 TXNS")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
