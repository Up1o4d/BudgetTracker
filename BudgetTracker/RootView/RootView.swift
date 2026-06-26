import SwiftUI

struct RootView: View {
    @State var router: AppRouter = .init()
    @State var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .idle:
                TabView(selection: router.selectedTabBinding) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        NavigationStack(path: router.navigationPathBinding(for: tab)) {
                            tabRoot(for: tab)
                                .safeAreaPadding(.bottom, AppTabBar.height)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .toolbar(.hidden, for: .tabBar)
                        .tabItem { Label(tab.name, systemImage: tab.systemImage) }
                        .tag(tab)
                        // TODO: - Add navigationDestination to resolve navigation screens
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    AppTabBar(tabs: Tab.allCases, selectedTab: router.selectedTabBinding)
                }
            case .error:
                // TODO: Localize these strings
                ContentUnavailableView {
                    Label("Something went wrong", systemImage: "exclamationmark.triangle")
                } description: {
                    Text("App failed to initialize properly")
                } actions: {
                    Button("Retry") {
                        Task { await viewModel.runAppSetup() }
                    }
                }
            }
        }
        .defaultScreenStyle()
        .task { await viewModel.runAppSetup() }
    }

    @ViewBuilder
    private func tabRoot(for tab: Tab) -> some View {
        switch tab {
        case .home:
            VStack {
                Text("home")
            }
            .frame(height: 50.0)
            .defaultScreenStyle()
        case .activity:
            ActivityView(viewModel: .init(
                transactionsProvider: viewModel.appDependencies.transactionsProvider,
                categoriesProvider: viewModel.appDependencies.categoriesProvider,
                appSettings: viewModel.appDependencies.appSettings
            ))
        case .add:
            AddView(viewModel: .init(
                transactionsProvider: viewModel.appDependencies.transactionsProvider
            ))
        }
    }
}
