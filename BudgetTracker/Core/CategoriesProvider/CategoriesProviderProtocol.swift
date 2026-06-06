protocol CategoriesProviderProtocol: Sendable {
    func fetchCategories() async throws -> [Category]
    func addCategories(_ categories: [Category]) async throws
}
