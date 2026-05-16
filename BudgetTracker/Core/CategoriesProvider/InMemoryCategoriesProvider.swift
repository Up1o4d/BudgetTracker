actor InMemoryCategoriesProvider: CategoriesProviderProtocol {
    private let categories: [Category]

    init(categories: [Category] = Category.all) {
        self.categories = categories
    }

    func fetchCategories() async throws -> [Category] {
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
        return categories
    }
}
