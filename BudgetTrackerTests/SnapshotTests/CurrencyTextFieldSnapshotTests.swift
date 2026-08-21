@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct CurrencyTextFieldSnapshotTests {
    // MARK: - Empty

    @Test
    func currencyTextField_empty_light() {
        let view = CurrencyTextField(amount: .constant(nil), currencyCode: "USD")
            .frame(width: 250)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func currencyTextField_empty_dark() {
        let view = CurrencyTextField(amount: .constant(nil), currencyCode: "USD")
            .frame(width: 250)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Populated, USD

    @Test
    func currencyTextField_populatedUSD_light() {
        let view = CurrencyTextField(amount: .constant(1234.56), currencyCode: "USD")
            .frame(width: 250)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func currencyTextField_populatedUSD_dark() {
        let view = CurrencyTextField(amount: .constant(1234.56), currencyCode: "USD")
            .frame(width: 250)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Populated, JPY (zero fraction digits)

    @Test
    func currencyTextField_populatedJPY_light() {
        let view = CurrencyTextField(amount: .constant(500), currencyCode: "JPY")
            .frame(width: 250)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func currencyTextField_populatedJPY_dark() {
        let view = CurrencyTextField(amount: .constant(500), currencyCode: "JPY")
            .frame(width: 250)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
