import SwiftUI

struct MonthCategorySpendingSummarySectionView: View {
    let category: Category
    let month: MonthYear
    let totalAmount: Decimal
    let transactionCount: Int
    let dailySpendingSums: [Decimal]
    let currency: String

    var body: some View {
        VStack {
            headerSection
            totalSection
            SpendingLineChart(
                values: dailySpendingSums,
                color: Color(hex: category.colorHex),
                xMax: month.numberOfDaysInMonth
            )
            .frame(height: 100.0)
        }
    }

    private var headerSection: some View {
        HStack {
            CategoryIconView(category: category)
            VStack {
                Text("CATEGORY · \(month.monthName)") // TODO: Localize
                Text(category.name)
            }
        }
    }

    private var totalSection: some View {
        VStack {
            Text(totalAmount, format: .currency(code: currency))
            Text("\(transactionCount) transactions") // TODO: Localize
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
}
