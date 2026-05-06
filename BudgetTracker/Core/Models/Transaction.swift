import Foundation

struct Transaction: Hashable, Identifiable {
    let id: String
    let amount: Decimal
    let vendor: String
    let category: Category
    let date: Date
}
