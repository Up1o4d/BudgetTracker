@testable import BudgetTracker
import Foundation
import Testing

struct RootViewModelTests {
    let categoriesProvider: MockCategoriesProvider
    let appSettings: InMemoryAppSettings
    let sut: RootViewModel

    init() {
        categoriesProvider = MockCategoriesProvider()
        appSettings = InMemoryAppSettings()
        sut = RootViewModel(
            appDependencies: AppDependencies(
                transactionsProvider: MockTransactionsProvider(),
                categoriesProvider: categoriesProvider,
                appSettings: appSettings
            )
        )
    }

    // MARK: - runAppSetup()

    @Test
    func runAppSetup_seedsCategories_onFirstRun() async {
        await sut.runAppSetup()

        #expect(categoriesProvider.addCategoriesCallCount == 1)
    }

    @Test
    func runAppSetup_doesNotSeedCategories_whenAlreadyRun() async {
        appSettings.isFirstLaunch = false

        await sut.runAppSetup()

        #expect(categoriesProvider.addCategoriesCallCount == 0)
    }

    @Test
    func runAppSetup_marksFirstRunComplete_afterSeeding() async {
        await sut.runAppSetup()

        #expect(!appSettings.isFirstLaunch)
    }

    @Test
    func runAppSetup_setsIsLoadingFalse_whenComplete() async {
        await sut.runAppSetup()

        #expect(!sut.isLoading)
    }
}
