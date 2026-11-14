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
                                .navigationDestination(for: AppRoute.self) { route in
                                    destination(for: route)
                                        .safeAreaPadding(.bottom, AppTabBar.height)
                                        .navigationBarTitleDisplayMode(.inline)
                                }
                        }
                        .toolbar(.hidden, for: .tabBar)
                        .tabItem { Label(tab.name, systemImage: tab.systemImage) }
                        .tag(tab)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    AppTabBar(
                        tabs: Tab.allCases,
                        selectedTab: router.selectedTabBinding,
                        addButtonAction: { router.presentedSheet = .addTransaction }
                    )
                }
                .sheet(item: router.presentedSheetBinding) { sheet in
                    switch sheet {
                    case .addTransaction:
                        AddView(viewModel: .init(
                            transactionsProvider: viewModel.appDependencies.transactionsProvider,
                            categoriesProvider: viewModel.appDependencies.categoriesProvider,
                            appSettings: viewModel.appDependencies.appSettings,
                            onSaved: { router.presentedSheet = nil }
                        ))
                    case .editBudget:
                        EditBudgetView(viewModel: .init(
                            appSettings: viewModel.appDependencies.appSettings,
                            onSaved: { router.presentedSheet = nil }
                        ))
                    }
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
        .screenDefaults()
        .task { await viewModel.runAppSetup() }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case let .monthCategorySpending(month, category):
            MonthCategorySpendingView(viewModel: .init(
                month: month,
                category: category,
                transactionsProvider: viewModel.appDependencies.transactionsProvider,
                appSettings: viewModel.appDependencies.appSettings
            ))
        }
    }

    @ViewBuilder
    private func tabRoot(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView(viewModel: .init(
                transactionsProvider: viewModel.appDependencies.transactionsProvider,
                categoriesProvider: viewModel.appDependencies.categoriesProvider,
                appSettings: viewModel.appDependencies.appSettings,
                router: router
            ))
        case .activity:
            ActivityView(viewModel: .init(
                transactionsProvider: viewModel.appDependencies.transactionsProvider,
                categoriesProvider: viewModel.appDependencies.categoriesProvider,
                appSettings: viewModel.appDependencies.appSettings
            ))
        }
    }
}
