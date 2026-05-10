protocol CategoriesProviderProtocol {
    func fetchCategories() async throws -> [Category]
}
