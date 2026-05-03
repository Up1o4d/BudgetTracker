import SwiftUI

@Observable
final class AppRouter {
    enum Tab: Hashable { case home, insights, activity, importing }

    private var selectedTab: Tab = .home
    private var paths: [Tab: NavigationPath] = [:]

    var selectedTabBinding: Binding<Tab> {
        Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )
    }

    func push<Route: Hashable>(_ route: Route, on tab: Tab? = nil) {
        let key = tab ?? selectedTab
        paths[key, default: NavigationPath()].append(route)
    }

    func pop(tab: Tab? = nil) {
        let key = tab ?? selectedTab
        guard let path = paths[key], !path.isEmpty else { return }
        paths[key]?.removeLast()
    }

    func popToRoot(tab: Tab? = nil) {
        paths[tab ?? selectedTab] = NavigationPath()
    }

    func navigationPathBinding(for tab: Tab) -> Binding<NavigationPath> {
        Binding(
            get: { self.paths[tab, default: NavigationPath()] },
            set: { self.paths[tab] = $0 }
        )
    }
}
