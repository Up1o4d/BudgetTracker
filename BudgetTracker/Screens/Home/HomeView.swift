import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel

    var body: some View {
        Group {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
            case .idle:
                monthPager
            case .error:
                ContentUnavailableView("screen.home.error", systemImage: "exclamationmark.triangle")
            }
        }
        .defaultScreenStyle()
        .navigationTitle("screen.home.title")
        .task { await viewModel.loadData() }
    }

    private var monthPager: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(viewModel.months, id: \.self) { month in
                    HomeMonthPageView(
                        summary: viewModel.summary(for: month),
                        budget: viewModel.budget,
                        currency: viewModel.currency
                    )
                    .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .defaultScrollAnchor(.trailing) // Current month is the last page
        .scrollPosition(id: selectedMonthBinding)
        .scrollIndicators(.hidden)
    }

    /// `scrollPosition(id:)` needs an optional binding; it only reports nil mid-layout, which we ignore.
    private var selectedMonthBinding: Binding<MonthYear?> {
        Binding(
            get: { viewModel.selectedMonthYear },
            set: { newValue in
                guard let newValue else { return }
                viewModel.selectedMonthYear = newValue
            }
        )
    }
}

#Preview {
    HomeView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
