@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct AddAmountSectionViewSnapshotTests {
    // MARK: - Empty

    @Test
    func addAmountSectionView_empty_light() {
        let view = AddAmountSectionView(amount: .constant(nil), currencyCode: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addAmountSectionView_empty_dark() {
        let view = AddAmountSectionView(amount: .constant(nil), currencyCode: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Populated

    @Test
    func addAmountSectionView_populated_light() {
        let view = AddAmountSectionView(amount: .constant(1234.56), currencyCode: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addAmountSectionView_populated_dark() {
        let view = AddAmountSectionView(amount: .constant(1234.56), currencyCode: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
