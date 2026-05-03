import SwiftUI

struct RootView: View {
    let appDependencies: AppDependencies
    @State var router: AppRouter = .init()

    var body: some View {
        TabView(selection: router.selectedTabBinding) {
            NavigationStack(path: router.navigationPathBinding(for: .home)) {
                Text("home")
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(AppRouter.Tab.home)

            NavigationStack(path: router.navigationPathBinding(for: .insights)) {
                Text("insights")
            }
            .tabItem { Label("Insights", systemImage: "waveform.path.ecg") }
            .tag(AppRouter.Tab.insights)

            NavigationStack(path: router.navigationPathBinding(for: .activity)) {
                ActivityView(
                    viewModel: .init(transactionsProvider: appDependencies.transactionsProvider)
                )
            }
            .tabItem { Label("Activity", systemImage: "list.bullet") }
            .tag(AppRouter.Tab.activity)

            NavigationStack(path: router.navigationPathBinding(for: .importing)) {
                Text("importing")
            }
            .tabItem { Label("Import", systemImage: "arrow.down.to.line") }
            .tag(AppRouter.Tab.importing)
        }
        // TODO: - Add navigationDestination to resolve navigation screens
    }
}
