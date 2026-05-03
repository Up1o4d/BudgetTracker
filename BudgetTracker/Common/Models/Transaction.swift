import Foundation

struct Transaction: Hashable, Identifiable {
    let id: String
    let amount: Float
    let vendor: String
    let category: Category
    let date: Date
}
