@testable import BudgetTracker
import Foundation
import SwiftData
import Testing

struct SwiftDataCategoriesProviderTests {
    let modelContainer: ModelContainer
    let userDefaults: UserDefaults
    let sut: SwiftDataCategoriesProvider

    init() throws {
        modelContainer = try ModelContainer(
            for: StoredCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        userDefaults = UserDefaults(suiteName: UUID().uuidString)!
        sut = SwiftDataCategoriesProvider(modelContainer: modelContainer, userDefaults: userDefaults)
    }

    // MARK: - fetchCategories()

    @Test
    func fetchCategories_seedsAllDefaultCategories_onFirstCall() async throws {
        let result = try await sut.fetchCategories()

        #expect(result.count == Category.all.count)
        #expect(Set(result.map(\.id)) == Set(Category.all.map(\.id)))
    }

    @Test
    func fetchCategories_doesNotDuplicateCategories_onSubsequentCalls() async throws {
        _ = try await sut.fetchCategories()
        let result = try await sut.fetchCategories()

        #expect(result.count == Category.all.count)
    }

    @Test
    func fetchCategories_skipsSeeding_whenAlreadyMarkedSeeded() async throws {
        userDefaults.set(true, forKey: "categoriesSeeded")

        let result = try await sut.fetchCategories()

        #expect(result.isEmpty)
    }
}
