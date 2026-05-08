import Foundation

struct Transaction: Hashable, Identifiable {
    let id: String
    let amount: Decimal
    let vendor: String
    let categoryId: String
    let date: Date
}
