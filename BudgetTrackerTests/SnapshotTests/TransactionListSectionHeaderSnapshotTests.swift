@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct TransactionListSectionHeaderSnapshotTests {
    @Test
    func transactionListSectionHeader_light() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let view = TransactionListSectionHeader(date: date, moneySpent: 500, currency: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func transactionListSectionHeader_dark() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let view = TransactionListSectionHeader(date: date, moneySpent: 500, currency: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
