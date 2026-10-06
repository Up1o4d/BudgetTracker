import Foundation

struct CategorySpending: Identifiable, Equatable {
    let category: Category
    let totalAmount: Decimal
    let percentageOfTotal: Double
    let roundedPercentage: Int

    var id: String {
        category.id
    }
}
