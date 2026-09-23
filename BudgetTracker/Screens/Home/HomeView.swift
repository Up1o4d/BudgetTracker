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
        Text("summary")
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
            Grid {
                ForEach(viewModel.categorySpending, id: \.category.id) { spending in
                    buildCategorySpendingRow(spending)
                }
            }
        }
        .cardBackground()
    }

    func buildCategorySpendingRow(_ spending: HomeViewModel.CategorySpending) -> some View {
        GridRow {
            CategoryIconView(category: spending.category)

            VStack(alignment: .leading) {
                Text(spending.category.name)
                if let maxCategorySpending = viewModel.maxCategorySpending {
                    let percentWidth = CGFloat(truncating: (spending.totalAmount / maxCategorySpending.totalAmount) as NSNumber)
                    Capsule()
                        .fill(Color.borderSubtle)
                        .frame(maxWidth: .infinity, maxHeight: 2.0)
                        .overlay {
                            GeometryReader { geo in
                                Capsule()
                                    .fill(Color(hex: spending.category.colorHex))
                                    .frame(width: geo.size.width * percentWidth)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                Text(spending.totalAmount, format: .currency(code: viewModel.currency))
                Text(spending.roundedPercentage, format: .percent)
                    .foregroundStyle(Color.textSecondary)
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
