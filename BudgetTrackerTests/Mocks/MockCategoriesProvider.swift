@testable import BudgetTracker

final class MockCategoriesProvider: CategoriesProviderProtocol, @unchecked Sendable {
    var stubbedCategories: [Category] = []
    var stubbedError: Error?
    private(set) var fetchCategoriesCallCount = 0
    private(set) var addCategoriesCallCount = 0

    func fetchCategories() async throws -> [Category] {
        fetchCategoriesCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedCategories
    }

    func addCategories(_ categories: [Category]) async throws {
        addCategoriesCallCount += 1
        if let error = stubbedError { throw error }
    }
}
