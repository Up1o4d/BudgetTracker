import Foundation

@Observable
final class RootViewModel {
    // TODO: Replace with a real state enum val
    private(set) var state: LoadingState = .loading
    let appDependencies: AppDependencies
    private var appSettings: any AppSettingsProtocol

    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        appSettings = appDependencies.appSettings
    }

    func runAppSetup() async {
        state = .loading
        do {
            if !appSettings.didSeedCategories {
                try await appDependencies.categoriesProvider.addCategories(Category.all)
                appSettings.didSeedCategories = false
            }

            if !appSettings.didSetCurrency {
                appSettings.currency = Locale.current.currency?.identifier ?? "USD"
                appSettings.didSetCurrency = true
            }

            state = .idle
        } catch {
            state = .error
        }
    }
}
