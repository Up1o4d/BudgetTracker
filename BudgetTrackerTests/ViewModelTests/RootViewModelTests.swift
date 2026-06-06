@testable import BudgetTracker
import Foundation
import Testing

struct RootViewModelTests {
    let categoriesProvider: MockCategoriesProvider
    let userDefaults: UserDefaults
    let sut: RootViewModel

    init() {
        categoriesProvider = MockCategoriesProvider()
        userDefaults = UserDefaults(suiteName: UUID().uuidString)!
        sut = RootViewModel(
            appDependencies: AppDependencies(
                transactionsProvider: MockTransactionsProvider(),
                categoriesProvider: categoriesProvider
            ),
            userDefaults: userDefaults
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
        userDefaults.set(true, forKey: "didRunFirstRunSetup")

        await sut.runAppSetup()

        #expect(categoriesProvider.addCategoriesCallCount == 0)
    }

    @Test
    func runAppSetup_marksFirstRunComplete_afterSeeding() async {
        await sut.runAppSetup()

        #expect(userDefaults.bool(forKey: "didRunFirstRunSetup"))
    }

    @Test
    func runAppSetup_setsIsLoadingFalse_whenComplete() async {
        await sut.runAppSetup()

        #expect(!sut.isLoading)
    }
}
