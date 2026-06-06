@testable import BudgetTracker
import Foundation
import SwiftData
import Testing

struct SwiftDataCategoriesProviderTests {
    let modelContainer: ModelContainer
    let sut: SwiftDataCategoriesProvider

    init() throws {
        modelContainer = try ModelContainer(
            for: StoredCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        sut = SwiftDataCategoriesProvider(modelContainer: modelContainer)
    }

    // MARK: - fetchCategories()

    @Test
    func fetchCategories_returnsEmpty_whenNoCategoriesAdded() async throws {
        let result = try await sut.fetchCategories()

        #expect(result.isEmpty)
    }

    @Test
    func fetchCategories_returnsAddedCategories() async throws {
        try await sut.addCategories(Category.all)

        let result = try await sut.fetchCategories()

        #expect(result.count == Category.all.count)
        #expect(Set(result.map(\.id)) == Set(Category.all.map(\.id)))
    }

    // MARK: - addCategories(_:)

    @Test
    func addCategories_persistsCategories() async throws {
        try await sut.addCategories(Category.all)

        let result = try await sut.fetchCategories()

        #expect(result.count == Category.all.count)
    }

    @Test
    func addCategories_appendsOnSubsequentCalls() async throws {
        try await sut.addCategories(Category.all)
        try await sut.addCategories(Category.all)

        let result = try await sut.fetchCategories()

        #expect(result.count == Category.all.count * 2)
    }
}
