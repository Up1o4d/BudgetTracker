final class InMemoryCategoriesProvider: CategoriesProviderProtocol {
    private let categories: [Category]

    init(categories: [Category] = Category.all) {
        self.categories = categories
    }

    func fetchCategories() async throws -> [Category] {
        categories
    }
}
