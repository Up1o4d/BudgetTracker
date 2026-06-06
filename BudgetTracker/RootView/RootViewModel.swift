import Foundation

@Observable
final class RootViewModel {
    // TODO: Replace with a real state enum val
    private(set) var isLoading: Bool = true
    let appDependencies: AppDependencies

    private let userDefaults: UserDefaults
    private let firstRunKey = "didRunFirstRunSetup"

    init(appDependencies: AppDependencies, userDefaults: UserDefaults = .standard) {
        self.appDependencies = appDependencies
        self.userDefaults = userDefaults
    }

    func runAppSetup() async {
        isLoading = true
        if !userDefaults.bool(forKey: firstRunKey) {
            // TODO: Error handling
            try? await appDependencies.categoriesProvider.addCategories(Category.all)
            userDefaults.set(true, forKey: firstRunKey)
        }
        isLoading = false
    }
}
