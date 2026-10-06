import SwiftUI

struct HomeCategorySpendingSectionView: View {
    let categorySpending: [CategorySpending]
    let currency: String
    let maxCategorySpending: CategorySpending?

    var body: some View {
        VStack {
            ForEach(categorySpending) { spending in
                HomeCategorySpendingRowView(
                    spending: spending,
                    currency: currency,
                    maxCategorySpending: maxCategorySpending
                )
                if let last = categorySpending.last, last != spending {
                    Divider()
                        .padding(.vertical, 8)
                }
            }
        }
        .cardBackground()
    }
}

#Preview {
    let categorySpending: [CategorySpending] = [
        .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
        .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
        .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
    ]

    HomeCategorySpendingSectionView(
        categorySpending: categorySpending,
        currency: "USD",
        maxCategorySpending: categorySpending.first
    )
    .padding()
}
