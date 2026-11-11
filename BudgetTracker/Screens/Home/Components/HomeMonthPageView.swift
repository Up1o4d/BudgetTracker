import SwiftUI

/// One page of the Home month pager: the dashboard sections for a single month.
struct HomeMonthPageView: View {
    let summary: MonthSummary
    let budget: Decimal?
    let currency: String
    var onBudgetTap: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                buildSectionWithLabels(
                    leading: summary.headerText,
                    trailing: "\(summary.transactionCount) TXNS" // TODO: Localize (with plural variants)
                ) {
                    HomeSummarySectionView(
                        categorySpending: summary.categorySpending,
                        totalCurrentMonthSpending: summary.totalSpending,
                        budget: budget,
                        currency: currency,
                        percentageOfBudgetSpent: summary.percentageOfBudgetSpent,
                        lastMonthSpendingDiffPercent: summary.lastMonthSpendingDiffPercent,
                        previousMonthName: summary.month.previousMonth.monthName,
                        onBudgetTap: onBudgetTap
                    )
                }

                buildSectionWithLabels(leading: "Month to date") { // TODO: Localize
                    HomeMonthToDateSpendingChartSection(
                        selectedMonth: summary.month,
                        currentMonthDailySpendingSums: summary.dailySpendingSums,
                        currency: currency
                    )
                }

                buildSectionWithLabels(leading: "By category") { // TODO: Localize
                    HomeCategorySpendingSectionView(
                        categorySpending: summary.categorySpending,
                        currency: currency,
                        maxCategorySpending: summary.maxCategorySpending
                    )
                }
            }
            .padding(16)
        }
    }

    func buildSectionWithLabels<Content: View>(leading: String, trailing: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack {
            HStack {
                Text(leading)
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                if let trailing = trailing {
                    Text(trailing)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .textStyle(.eyebrow)
            content()
                .if(summary.isLoading) { view in
                    view.redacted(reason: .placeholder).shimmering()
                }
        }
    }
}

#Preview {
    HomeMonthPageView(
        summary: MonthSummary(
            month: .current(),
            headerText: MonthYear.current().displayName,
            totalSpending: 1050,
            transactionCount: 52,
            percentageOfBudgetSpent: 0.46,
            lastMonthSpendingDiffPercent: -0.12,
            categorySpending: [
                .init(category: .groceries, totalAmount: 420, percentageOfTotal: 0.4, roundedPercentage: 40),
                .init(category: .rent, totalAmount: 380, percentageOfTotal: 0.36, roundedPercentage: 36),
                .init(category: .dining, totalAmount: 250, percentageOfTotal: 0.24, roundedPercentage: 24),
            ],
            dailySpendingSums: [400, 0, 120, 80, 0, 450],
            isLoading: false
        ),
        budget: 2300,
        currency: "USD"
    )
    .screenDefaults()
}
