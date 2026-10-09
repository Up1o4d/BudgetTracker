import Charts
import SwiftUI

struct HomeMonthToDateSpendingChartSection: View {
    let currentMonthDailySpendingSums: [Decimal]

    var body: some View {
        Chart {
            ForEach(currentMonthDailySpendingSums.enumerated(), id: \.offset) { inx, value in
                LineMark(x: .value("Day", inx + 1),
                         y: .value("Value", value))
            }
        }
        .chartXScale(domain: 1 ... (currentMonthDailySpendingSums.count - 1))
        .frame(maxHeight: 200)
    }
}

#Preview {
    let dailySpendingSums: [Decimal] = [
        12.99, 34.55, 99.12, 34.55, 189.20, 499.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 189.20, 499.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 189.20, 499.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 189.20, 499.10, 9.11,
    ]
    HomeMonthToDateSpendingChartSection(
        currentMonthDailySpendingSums: dailySpendingSums
    )
}
