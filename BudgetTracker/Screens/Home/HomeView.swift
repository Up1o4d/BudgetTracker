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
}

#Preview {
    HomeView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
