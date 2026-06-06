import SwiftUI

struct RootView: View {
    @State var router: AppRouter = .init()
    @State var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                TabView(selection: router.selectedTabBinding) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        NavigationStack(path: router.navigationPathBinding(for: tab)) {
                            tabRoot(for: tab)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .tabItem { Label(tab.name, systemImage: tab.systemImage) }
                        .tag(tab)
                    }
                }
                // TODO: - Add navigationDestination to resolve navigation screens
            }
        }
        .defaultScreenStyle()
        .task { await viewModel.runAppSetup() }
    }

    @ViewBuilder
    private func tabRoot(for tab: Tab) -> some View {
        switch tab {
        case .home: Text("home")
        case .activity:
            ActivityView(viewModel: .init(
                transactionsProvider: viewModel.appDependencies.transactionsProvider,
                categoriesProvider: viewModel.appDependencies.categoriesProvider
            ))
        case .add: Text("Add")
            AddView(viewModel: .init(
                transactionsProvider: viewModel.appDependencies.transactionsProvider
            ))
        }
    }
}
