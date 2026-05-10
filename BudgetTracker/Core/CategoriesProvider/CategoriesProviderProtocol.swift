protocol CategoriesProviderProtocol: Sendable {
    func fetchCategories() async throws -> [Category]
}
