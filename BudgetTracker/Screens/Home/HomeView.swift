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
                    HomeSummarySectionView(
                        categorySpending: viewModel.categorySpending,
                        totalCurrentMonthSpending: viewModel.totalCurrentMonthSpending,
                        budget: viewModel.budget,
                        currency: viewModel.currency,
                        percentageOfBudgetSpent: viewModel.percentageOfBudgetSpent,
                        lastMonthSpendingDiffPercent: viewModel.lastMonthSpendingDiffPercent,
                        previousMonthName: viewModel.selectedMonthYear.previousMonth.monthName
                    )
                    HomeMonthToDateSpendingChartSection(
                        selectedMonth: viewModel.selectedMonthYear,
                        currentMonthDailySpendingSums: viewModel.currentMonthDailySpendingSums,
                        currency: viewModel.currency
                    )
                    // TODO: temporary month-switching controls, replace with real UI
                    HStack {
                        Button("Previous month") { viewModel.selectPreviousMonth() }
                        Spacer()
                        Button("Next month") { viewModel.selectNextMonth() }
                    }
                    HomeCategorySpendingSectionView(
                        categorySpending: viewModel.categorySpending,
                        currency: viewModel.currency,
                        maxCategorySpending: viewModel.maxCategorySpending
                    )
                }
            case .error:
                ContentUnavailableView("screen.home.error", systemImage: "exclamationmark.triangle")
            }
        }
        .defaultScreenStyle()
        .navigationTitle("screen.home.title")
        .task { await viewModel.loadData() }
    }
}

#Preview {
    HomeView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
