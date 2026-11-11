import Charts
import SwiftUI

struct HomeSummarySectionView: View {
    @Environment(\.redactionReasons) var redactionReasons

    let categorySpending: [CategorySpending]
    let totalCurrentMonthSpending: Decimal
    let budget: Decimal?
    let currency: String
    let percentageOfBudgetSpent: Double
    let lastMonthSpendingDiffPercent: Double?
    let previousMonthName: String
    var onBudgetTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                donutChartWithSpendingView
                budgetSectionView
            }
            if !categorySpending.isEmpty {
                linearChartView
                legendView
            }
        }
        .cardBackground()
    }

    var donutChartWithSpendingView: some View {
        ZStack {
            let chartSize: CGFloat = 160
            // Gray placeholder ring; fully covered by the real chart's sectors unless categorySpending is empty
            Chart {
                SectorMark(angle: .value("Empty", 1), innerRadius: .ratio(0.75))
                    .foregroundStyle(Color.borderSubtle)
            }
            .frame(width: chartSize, height: chartSize)
            if redactionReasons.isEmpty {
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
            }
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
        Button(action: onBudgetTap) {
            budgetSectionContent
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!redactionReasons.isEmpty)
    }

    var budgetSectionContent: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Text("BUDGET")
                Image(systemName: "pencil")
            }
            .textStyle(.eyebrow)
            .foregroundStyle(Color.textTertiary)

            HStack(spacing: 4) {
                Text(totalCurrentMonthSpending, format: .currency(code: currency))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                Text("/")
                if let budget {
                    Text(budget, format: .currency(code: currency))
                        .foregroundStyle(Color.textSecondary)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                } else {
                    Text("Set budget") // TODO: Localize
                        .foregroundStyle(Color.accentLime)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                }
            }

            PercentageBar(
                percentage: redactionReasons.isEmpty ? percentageOfBudgetSpent : 0.0,
                foregroundBarColor: Color.accentLime,
                height: 8.0
            )

            if let lastMonthSpendingDiffPercent = lastMonthSpendingDiffPercent {
                let percentageString = String(format: "%.1f", abs(lastMonthSpendingDiffPercent) * 100)
                var arrowAndColor: (arrow: String?, color: Color) {
                    if lastMonthSpendingDiffPercent == 0 || !redactionReasons.isEmpty {
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
            if redactionReasons.isEmpty {
                HStack(spacing: 0) {
                    ForEach(categorySpending, id: \.category.id) { spending in
                        Capsule()
                            .fill(Color(hex: spending.category.colorHex))
                            .frame(width: geo.size.width * spending.percentageOfTotal)
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                Capsule()
                    .fill(Color.borderSubtle)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 10)
    }

    var legendView: some View {
        FlowLayout {
            ForEach(categorySpending, id: \.category.id) { spending in
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(redactionReasons.isEmpty ? Color(hex: spending.category.colorHex) : Color.borderSubtle)
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

#Preview("Loaded") {
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

#Preview("Redacted") {
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
    .redacted(reason: .placeholder)
}

#Preview("No budget") {
    HomeSummarySectionView(
        categorySpending: [
            .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
            .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
            .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
        ],
        totalCurrentMonthSpending: 1050,
        budget: nil,
        currency: "USD",
        percentageOfBudgetSpent: 0,
        lastMonthSpendingDiffPercent: 0.12,
        previousMonthName: "September"
    )
    .padding()
}

#Preview("Empty") {
    HomeSummarySectionView(
        categorySpending: [],
        totalCurrentMonthSpending: 0,
        budget: 2300,
        currency: "USD",
        percentageOfBudgetSpent: 0 / 2300.0,
        lastMonthSpendingDiffPercent: 0,
        previousMonthName: "September"
    )
    .padding()
}
