import SwiftUI

struct HomeCategorySpendingSectionView: View {
    let categorySpending: [CategorySpending]
    let currency: String
    let maxCategorySpending: CategorySpending?
    var onCategoryTap: (Category) -> Void = { _ in }

    var body: some View {
        VStack {
            if categorySpending.isEmpty {
                emptyState
            } else {
                ForEach(categorySpending) { spending in
                    Button { onCategoryTap(spending.category) } label: {
                        HomeCategorySpendingRowView(
                            spending: spending,
                            currency: currency,
                            maxCategorySpending: maxCategorySpending
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if let last = categorySpending.last, last != spending {
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .cardBackground()
    }

    private var emptyState: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.textTertiary.opacity(0.2))
                .stroke(Color.textTertiary, lineWidth: 1.0)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "chart.pie")
                        .foregroundStyle(Color.textTertiary)
                )

            Text("No spending yet")
                .textStyle(.bodyMD)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.vertical, 24)
    }
}

#Preview("Loaded") {
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

#Preview("Empty") {
    HomeCategorySpendingSectionView(
        categorySpending: [],
        currency: "USD",
        maxCategorySpending: nil
    )
    .padding()
}

#Preview("Redacted") {
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
    .redacted(reason: .placeholder)
}
