import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        Group {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
            case .idle:
                VStack(spacing: 16) {
                    buildSectionWithLabels(
                        leading: viewModel.selectedMonthHeaderText,
                        trailing: "52 TXNS" // TODO: Localize
                    ) {
                        HomeSummarySectionView(
                            categorySpending: viewModel.categorySpending,
                            totalCurrentMonthSpending: viewModel.totalCurrentMonthSpending,
                            budget: viewModel.budget,
                            currency: viewModel.currency,
                            percentageOfBudgetSpent: viewModel.percentageOfBudgetSpent,
                            lastMonthSpendingDiffPercent: viewModel.lastMonthSpendingDiffPercent,
                            previousMonthName: viewModel.selectedMonthYear.previousMonth.monthName
                        )
                    }

                    buildSectionWithLabels(leading: "Month to date") { // TODO: Localize
                        HomeMonthToDateSpendingChartSection(
                            selectedMonth: viewModel.selectedMonthYear,
                            currentMonthDailySpendingSums: viewModel.currentMonthDailySpendingSums,
                            currency: viewModel.currency
                        )
                    }

                    buildSectionWithLabels(leading: "By category") { // TODO: Localize
                        HomeCategorySpendingSectionView(
                            categorySpending: viewModel.categorySpending,
                            currency: viewModel.currency,
                            maxCategorySpending: viewModel.maxCategorySpending
                        )
                    }

                    // TODO: temporary month-switching controls, replace with real UI
                    HStack {
                        Button("Previous month") { viewModel.selectPreviousMonth() }
                        Spacer()
                        Button("Next month") { viewModel.selectNextMonth() }
                    }
                }
                .padding(16)
            case .error:
                ContentUnavailableView("screen.home.error", systemImage: "exclamationmark.triangle")
            }
        }
        .defaultScreenStyle()
        .navigationTitle("screen.home.title")
        .task { await viewModel.loadData() }
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
