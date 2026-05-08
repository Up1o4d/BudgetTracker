import Foundation
import SwiftData

@Model
class StoredTransaction {
    var id: String
    var amount: Decimal
    var vendor: String
    var categoryId: String
    var date: Date

    init(id: String, amount: Decimal, vendor: String, categoryId: String, date: Date) {
        self.id = id
        self.amount = amount
        self.vendor = vendor
        self.categoryId = categoryId
        self.date = date
    }

    convenience init(transaction: Transaction) {
        self.init(
            id: transaction.id,
            amount: transaction.amount,
            vendor: transaction.vendor,
            categoryId: transaction.categoryId,
            date: transaction.date
        )
    }

    var asTransaction: Transaction {
        Transaction(
            id: id,
            amount: amount,
            vendor: vendor,
            categoryId: categoryId,
            date: date
        )
    }
}
