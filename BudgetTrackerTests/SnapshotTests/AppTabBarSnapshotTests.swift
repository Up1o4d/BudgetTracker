@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct AppTabBarSnapshotTests {

    // MARK: - Home tab selected

    @Test
    func appTabBar_homeSelected_light() {
        let view = AppTabBar(tabs: Tab.allCases, selectedTab: .constant(.home))
            .frame(width: 375, height: AppTabBar.height)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func appTabBar_homeSelected_dark() {
        let view = AppTabBar(tabs: Tab.allCases, selectedTab: .constant(.home))
            .frame(width: 375, height: AppTabBar.height)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Activity tab selected

    @Test
    func appTabBar_activitySelected_light() {
        let view = AppTabBar(tabs: Tab.allCases, selectedTab: .constant(.activity))
            .frame(width: 375, height: AppTabBar.height)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func appTabBar_activitySelected_dark() {
        let view = AppTabBar(tabs: Tab.allCases, selectedTab: .constant(.activity))
            .frame(width: 375, height: AppTabBar.height)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
