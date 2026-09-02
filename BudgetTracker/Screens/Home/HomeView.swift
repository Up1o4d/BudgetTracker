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
            ForEach(viewModel.categorySpending, id: \.category.id) { spending in
                HStack(spacing: 12) {
                    Image(systemName: spending.category.symbolName)
                        .foregroundStyle(Color(hex: spending.category.colorHex))
                    Text(spending.category.name)
                    Spacer()
                    Text(spending.percentageOfTotal, format: .percent)
                        .foregroundStyle(Color.textSecondary)
                    Text(spending.totalAmount, format: .currency(code: viewModel.currency))
                }
            }
        }
        .cardBackground()
    }
}

#Preview {
    HomeView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
