import Foundation

protocol CategoriesProviderProtocol: Sendable {
    func categoriesStream() async -> (AsyncStream<DataState<Category>>, UUID)

    @discardableResult
    func fetchCategories(uuid: UUID) async -> Result<[Category], Error>

    func addCategories(_ categories: [Category]) async throws
}
