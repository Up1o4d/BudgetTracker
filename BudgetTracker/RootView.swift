import SwiftUI

struct RootView: View {
    let appDependencies: AppDependencies
    @State var router: AppRouter = .init()

    var body: some View {
        TabView(selection: router.selectedTabBinding) {
            ForEach(Tab.allCases, id: \.self) { tab in
                NavigationStack(path: router.navigationPathBinding(for: tab)) {
                    tabRoot(for: tab)
                }
                .tabItem { Label(tab.name, systemImage: tab.systemImage) }
                .tag(tab)
            }
        }
        .defaultScreenStyle()
        // TODO: - Add navigationDestination to resolve navigation screens
    }

    @ViewBuilder
    private func tabRoot(for tab: Tab) -> some View {
        switch tab {
        case .home: Text("home")
        case .activity:
            ActivityView(
                viewModel: .init(transactionsProvider: appDependencies.transactionsProvider)
            )
        }
    }
}
