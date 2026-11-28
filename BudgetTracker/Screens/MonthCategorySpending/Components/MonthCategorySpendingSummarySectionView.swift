import SwiftUI

struct MonthCategorySpendingSummarySectionView: View {
    @Environment(\.redactionReasons) var redactionReasons

    let category: Category
    let month: MonthYear
    let totalAmount: Decimal
    let transactionCount: Int
    let dailySpendingSums: [Decimal]
    let currency: String

    private var chartValues: [Decimal] {
        guard redactionReasons.isEmpty else { return [] }
        return dailySpendingSums
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            totalSection
            SpendingLineChart(
                values: chartValues,
                color: Color(hex: category.colorHex),
                xMax: month.numberOfDaysInMonth
            )
            .frame(height: 100.0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground(tint: Color(hex: category.colorHex))
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            CategoryIconView(category: category, size: .large)
            VStack(alignment: .leading, spacing: 2) {
                Text("CATEGORY · \(month.monthName)") // TODO: Localize
                    .textStyle(.eyebrow)
                    .foregroundStyle(Color.textTertiary)
                Text(category.name)
                    .textStyle(.titleMD)
                    .foregroundStyle(Color.textPrimary)
            }
        }
    }

    private var totalSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(totalAmount, format: .currency(code: currency))
                .textStyle(.displayXL)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(transactionCount) transactions") // TODO: Localize
                .textStyle(.bodyXS)
                .foregroundStyle(Color.textSecondary)
        }
    }
}

#Preview("Loaded") {
    let dailySpendingSums: [Decimal] = [
        0.0, 12.99, 0.0, 34.55, 0.0, 0.0, 99.12,
        0.0, 0.0, 34.55, 0.0, 28.20, 0.0, 9.11,
        0.0, 12.99, 0.0, 0.0, 41.30, 0.0, 0.0,
        19.75, 0.0, 0.0, 64.10, 0.0, 0.0, 22.40,
    ]
    MonthCategorySpendingSummarySectionView(
        category: .groceries,
        month: .current().previousMonth,
        totalAmount: dailySpendingSums.reduce(Decimal.zero, +),
        transactionCount: 12,
        dailySpendingSums: dailySpendingSums,
        currency: "USD"
    )
    .padding()
}

#Preview("Empty") {
    MonthCategorySpendingSummarySectionView(
        category: .groceries,
        month: .current().previousMonth,
        totalAmount: 0,
        transactionCount: 0,
        dailySpendingSums: [],
        currency: "USD"
    )
    .padding()
}

#Preview("Redacted") {
    let dailySpendingSums: [Decimal] = [
        0.0, 12.99, 0.0, 34.55, 0.0, 0.0, 99.12,
        0.0, 0.0, 34.55, 0.0, 28.20, 0.0, 9.11,
    ]
    MonthCategorySpendingSummarySectionView(
        category: .groceries,
        month: .current().previousMonth,
        totalAmount: dailySpendingSums.reduce(Decimal.zero, +),
        transactionCount: 12,
        dailySpendingSums: dailySpendingSums,
        currency: "USD"
    )
    .padding()
    .redacted(reason: .placeholder)
}
