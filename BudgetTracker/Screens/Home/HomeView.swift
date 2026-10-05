import Charts
import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        Group {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
            case .idle:
                VStack {
                    summarySection
                    categorySpendingSection
                }
            case .error:
                ContentUnavailableView("screen.home.error", systemImage: "exclamationmark.triangle")
            }
        }
        .defaultScreenStyle()
        .navigationTitle("screen.home.title")
        .task { await viewModel.loadData() }
    }

    var summarySection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    let chartSize: CGFloat = 160
                    Chart(viewModel.categorySpending) { catSpending in
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
                        Text(viewModel.totalCurrentMonthSpending, format: .currency(code: viewModel.currency))
                            .textStyle(.displayLG)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                    }
                    .frame(width: 112)
                }

                VStack(alignment: .leading) {
                    Text("BUDGET")
                        .textStyle(.eyebrow)
                        .foregroundStyle(Color.textTertiary)
                    HStack(spacing: 4) {
                        Text(viewModel.totalCurrentMonthSpending, format: .currency(code: viewModel.currency))
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                        Text("/")
                        Text(viewModel.budget, format: .currency(code: viewModel.currency))
                            .foregroundStyle(Color.textSecondary)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                    }

                    buildPercentageBar(
                        percentage: viewModel.percentageOfBudgetSpent,
                        foregroundBarColor: Color.accentLime,
                        height: 8.0
                    )

                    if let lastMonthSpendingDiffPercent = viewModel.lastMonthSpendingDiffPercent {
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
                            Text("vs \(viewModel.previousMonthName)")
                                .foregroundStyle(Color.textSecondary)
                        }
                        .textStyle(.bodyXS)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(viewModel.categorySpending, id: \.category.id) { spending in
                        Capsule()
                            .fill(Color(hex: spending.category.colorHex))
                            .frame(width: geo.size.width * spending.percentageOfTotal)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 10)

            FlowLayout {
                ForEach(viewModel.categorySpending, id: \.category.id) { spending in
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: spending.category.colorHex))
                            .frame(width: 8, height: 8)
                            .padding(.bottom, 2)

                        Text(spending.category.name)

                        Text("·")

                        Text(spending.totalAmount, format: .currency(code: viewModel.currency))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .textStyle(.metadata)
                    .foregroundStyle(Color.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardBackground()
    }

    var categorySpendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TODO: temporary month-switching controls, replace with real UI
            HStack {
                Button("Previous month") { viewModel.selectPreviousMonth() }
                Spacer()
                Button("Next month") { viewModel.selectNextMonth() }
            }
            VStack {
                ForEach(viewModel.categorySpending) { spending in
                    buildCategorySpendingRow(spending)
                    if let last = viewModel.categorySpending.last, last != spending {
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
            }
            .cardBackground()
        }
    }

    func buildCategorySpendingRow(_ spending: HomeViewModel.CategorySpending) -> some View {
        HStack {
            CategoryIconView(category: spending.category)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(spending.category.name)
                        .textStyle(.bodyMD)
                    Spacer()
                    Text(spending.totalAmount, format: .currency(code: viewModel.currency))
                        .textStyle(.bodyMDSemibold)
                }
                if let maxCategorySpending = viewModel.maxCategorySpending {
                    HStack {
                        buildPercentageBar(
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

    func buildPercentageBar(
        percentage: Double,
        backgroundBarColor: Color = Color.borderSubtle,
        foregroundBarColor: Color,
        overflowColor: Color = Color.statusNegative,
        height: CGFloat = 2.0
    ) -> some View {
        Capsule()
            .fill(backgroundBarColor)
            .frame(maxWidth: .infinity, maxHeight: height)
            .overlay {
                GeometryReader { geo in
                    var barWidths: (foregroundWidth: CGFloat, overflowWidth: CGFloat?) {
                        if percentage < 1.0 {
                            return (foregroundWidth: geo.size.width * percentage, overflowWidth: nil)
                        }
                        let overflowShare: Double = percentage - 1.0
                        return (
                            foregroundWidth: (1.0 / percentage) * geo.size.width,
                            overflowWidth: (1.0 / percentage) * overflowShare * geo.size.width
                        )
                    }

                    HStack(spacing: 0.0) {
                        Rectangle()
                            .fill(foregroundBarColor)
                            .frame(width: barWidths.foregroundWidth)
                        if let overflowWidth: CGFloat = barWidths.overflowWidth {
                            Rectangle()
                                .fill(overflowColor)
                                .frame(width: overflowWidth)
                        }
                    }
                    .clipShape(Capsule())
                }
            }
    }
}

#Preview {
    HomeView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
