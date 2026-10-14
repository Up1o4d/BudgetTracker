import Charts
import SwiftUI

struct HomeSummarySectionView: View {
    let categorySpending: [CategorySpending]
    let totalCurrentMonthSpending: Decimal
    let budget: Decimal
    let currency: String
    let percentageOfBudgetSpent: Double
    let lastMonthSpendingDiffPercent: Double?
    let previousMonthName: String

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                donutChartWithSpendingView
                budgetSectionView
            }
            linearChartView
            legendView
        }
        .cardBackground()
    }

    var donutChartWithSpendingView: some View {
        ZStack {
            let chartSize: CGFloat = 160
            Chart(categorySpending) { catSpending in
                SectorMark(
                    angle: .value(
                        catSpending.category.name,
                        catSpending.percentageOfTotal
                    ),
                    innerRadius: .ratio(0.75)
                )
                .foregroundStyle(Color(hex: catSpending.category.colorHex))
            }
            .frame(width: chartSize, height: chartSize)
            VStack {
                Text("SPENT")
                    .textStyle(.eyebrow)
                    .foregroundStyle(Color.textTertiary)
                Text(totalCurrentMonthSpending, format: .currency(code: currency))
                    .textStyle(.displayLG)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
            }
            .frame(width: 112)
        }
    }

    var budgetSectionView: some View {
        VStack(alignment: .leading) {
            Text("BUDGET")
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textTertiary)
            HStack(spacing: 4) {
                Text(totalCurrentMonthSpending, format: .currency(code: currency))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                Text("/")
                Text(budget, format: .currency(code: currency))
                    .foregroundStyle(Color.textSecondary)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
            }

            PercentageBar(
                percentage: percentageOfBudgetSpent,
                foregroundBarColor: Color.accentLime,
                height: 8.0
            )

            if let lastMonthSpendingDiffPercent = lastMonthSpendingDiffPercent {
                let percentageString = String(format: "%.1f", abs(lastMonthSpendingDiffPercent) * 100)
                var arrowAndColor: (arrow: String?, color: Color) {
                    if lastMonthSpendingDiffPercent == 0 {
                        return (arrow: nil, color: Color.statusNeutral)
                    } else if lastMonthSpendingDiffPercent > 0 {
                        return (arrow: "arrow.up", color: Color.statusNegative)
                    } else {
                        return (arrow: "arrow.down", color: Color.statusPositive)
                    }
                }
                HStack(spacing: 4) {
                    if let arrow = arrowAndColor.arrow {
                        Image(systemName: arrow)
                            .foregroundStyle(arrowAndColor.color)
                    }
                    Text("\(percentageString)%")
                        .foregroundStyle(arrowAndColor.color)
                    Text("vs \(previousMonthName)")
                        .foregroundStyle(Color.textSecondary)
                }
                .textStyle(.bodyXS)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var linearChartView: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(categorySpending, id: \.category.id) { spending in
                    Capsule()
                        .fill(Color(hex: spending.category.colorHex))
                        .frame(width: geo.size.width * spending.percentageOfTotal)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 10)
    }

    var legendView: some View {
        FlowLayout {
            ForEach(categorySpending, id: \.category.id) { spending in
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: spending.category.colorHex))
                        .frame(width: 8, height: 8)
                        .padding(.bottom, 2)

                    Text(spending.category.name)

                    Text("·")

                    Text(spending.totalAmount, format: .currency(code: currency))
                        .foregroundStyle(Color.textPrimary)
                }
                .textStyle(.metadata)
                .foregroundStyle(Color.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let categorySpending: [CategorySpending] = [
        .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
        .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
        .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
    ]

    HomeSummarySectionView(
        categorySpending: categorySpending,
        totalCurrentMonthSpending: 1050,
        budget: 2300,
        currency: "USD",
        percentageOfBudgetSpent: 1050.0 / 2300.0,
        lastMonthSpendingDiffPercent: 0.12,
        previousMonthName: "September"
    )
    .padding()
}
