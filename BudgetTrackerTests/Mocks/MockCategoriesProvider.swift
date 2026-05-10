@testable import BudgetTracker

final class MockCategoriesProvider: CategoriesProviderProtocol {
    var stubbedCategories: [Category] = []
    var stubbedError: Error?
    private(set) var fetchCategoriesCallCount = 0

    func fetchCategories() async throws -> [Category] {
        fetchCategoriesCallCount += 1
        if let error = stubbedError {
            throw error
        }
        return stubbedCategories
    }
}
