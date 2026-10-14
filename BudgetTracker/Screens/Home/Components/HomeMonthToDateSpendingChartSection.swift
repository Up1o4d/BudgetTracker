import Charts
import SwiftUI

struct HomeMonthToDateSpendingChartSection: View {
    let selectedMonth: MonthYear
    let currentMonthDailySpendingSums: [Decimal]
    let currency: String

    private var chartColor: Color {
        Color.accentLime
    }

    private var linearGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    chartColor.opacity(0.4),
                    chartColor.opacity(0),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var averageDailySpending: Decimal {
        let totalSpending: Decimal = currentMonthDailySpendingSums.reduce(Decimal.zero, +)
        return totalSpending / Decimal(currentMonthDailySpendingSums.count)
    }

    private var todaySpending: Decimal {
        currentMonthDailySpendingSums.last ?? 0.0
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
            Chart {
                ForEach(currentMonthDailySpendingSums.enumerated(), id: \.offset) { inx, value in
                    LineMark(x: .value("Day", inx + 1),
                             y: .value("Value", value))
                }
                .foregroundStyle(chartColor)

                ForEach(currentMonthDailySpendingSums.enumerated(), id: \.offset) { inx, value in
                    AreaMark(x: .value("Day", inx + 1),
                             y: .value("Value", value))
                }
                .foregroundStyle(linearGradient)
            }
            .chartXScale(domain: 1 ... selectedMonth.numberOfDaysInMonth)
            .frame(height: 150)
        }
        .cardBackground()
    }

    func buildStatsLabel(label: String, value: String, alignment: HorizontalAlignment) -> some View {
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

#Preview {
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
