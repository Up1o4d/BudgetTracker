@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct TransactionListCellSnapshotTests {
    @Test
    func transactionListCell_groceries_light() {
        let transaction = Transaction(
            id: "1",
            amount: 54.30,
            vendor: "Whole Foods",
            categoryId: Category.groceries.id,
            date: Date()
        )
        let view = TransactionListCell(transaction: transaction, category: .groceries, currency: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func transactionListCell_groceries_dark() {
        let transaction = Transaction(
            id: "1",
            amount: 54.30,
            vendor: "Whole Foods",
            categoryId: Category.groceries.id,
            date: Date()
        )
        let view = TransactionListCell(transaction: transaction, category: .groceries, currency: "USD")
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
