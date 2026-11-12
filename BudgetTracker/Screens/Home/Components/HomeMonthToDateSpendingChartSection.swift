import SwiftUI

struct HomeMonthToDateSpendingChartSection: View {
    @Environment(\.redactionReasons) var redactionReasons

    let selectedMonth: MonthYear
    let currentMonthDailySpendingSums: [Decimal]
    let currency: String

    private var spendingSums: [Decimal] {
        guard redactionReasons.isEmpty else { return [] }
        return currentMonthDailySpendingSums
    }

    private var averageDailySpending: Decimal {
        let totalSpending: Decimal = spendingSums.reduce(Decimal.zero, +)
        guard totalSpending > 0 else { return 0 }
        return totalSpending / Decimal(spendingSums.count)
    }

    private var todaySpending: Decimal {
        spendingSums.last ?? 0.0
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                buildStatsLabel(
                    label: "today", // TODO: Localize
                    value: todaySpending.formatted(.currency(code: currency)),
                    alignment: .leading
                )
                Spacer()
                buildStatsLabel(
                    label: "avg/day", // TODO: Localize
                    value: averageDailySpending.formatted(.currency(code: currency)),
                    alignment: .trailing
                )
            }
            SpendingLineChart(
                values: spendingSums,
                color: .accentLime,
                xMax: selectedMonth.numberOfDaysInMonth
            )
            .frame(height: 150)
        }
        .cardBackground()
    }

    private func buildStatsLabel(label: String, value: String, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Text(label)
                .textStyle(.metadata)
                .foregroundStyle(Color.textSecondary)
            Text(value)
                .textStyle(.bodyMDSemibold)
                .foregroundStyle(Color.textPrimary)
        }
    }
}

#Preview("Loaded") {
    let dailySpendingSums: [Decimal] = [
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        12.99, 34.55, 99.12, 34.55, 289.20, 599.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 0.00, 499.10, 10.0,
    ]
    HomeMonthToDateSpendingChartSection(
        selectedMonth: MonthYear.current(),
        currentMonthDailySpendingSums: dailySpendingSums,
        currency: "USD"
    )
}

#Preview("Empty") {
    HomeMonthToDateSpendingChartSection(
        selectedMonth: MonthYear.current(),
        currentMonthDailySpendingSums: [],
        currency: "USD"
    )
}

#Preview("Redacted") {
    let dailySpendingSums: [Decimal] = [
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        12.99, 34.55, 99.12, 34.55, 289.20, 599.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 0.00, 499.10, 10.0,
    ]
    HomeMonthToDateSpendingChartSection(
        selectedMonth: MonthYear.current(),
        currentMonthDailySpendingSums: dailySpendingSums,
        currency: "USD"
    )
    .redacted(reason: .placeholder)
}
