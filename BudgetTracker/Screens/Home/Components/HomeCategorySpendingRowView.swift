import SwiftUI

struct HomeCategorySpendingRowView: View {
    let spending: CategorySpending
    let currency: String
    let maxCategorySpending: CategorySpending?

    var body: some View {
        HStack {
            CategoryIconView(category: spending.category)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(spending.category.name)
                        .textStyle(.bodyMD)
                    Spacer()
                    Text(spending.totalAmount, format: .currency(code: currency))
                        .textStyle(.bodyMDSemibold)
                }
                if let maxCategorySpending = maxCategorySpending {
                    HStack {
                        PercentageBar(
                            percentage: Double(truncating: (spending.totalAmount / maxCategorySpending.totalAmount) as NSNumber),
                            foregroundBarColor: Color(hex: spending.category.colorHex)
                        )

                        Text(spending.roundedPercentage, format: .percent)
                            .textStyle(.metadata)
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 64, alignment: .trailing)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let groceries = CategorySpending(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40)
    let dining = CategorySpending(category: .dining, totalAmount: 180, percentageOfTotal: 0.17, roundedPercentage: 17)

    VStack(spacing: 16) {
        HomeCategorySpendingRowView(spending: groceries, currency: "USD", maxCategorySpending: groceries)
        HomeCategorySpendingRowView(spending: dining, currency: "USD", maxCategorySpending: groceries)
    }
    .padding()
}
