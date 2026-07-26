import Foundation

actor InMemoryCategoriesProvider: CategoriesProviderProtocol {
    private var categoriesDict: [String: Category]
    private let registry = DataStreamRegistry<Category>()

    init(categories: [Category] = Category.all) {
        categoriesDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
    }

    func categoriesStream() async -> (AsyncStream<DataState<Category>>, UUID) {
        await registry.makeStream()
    }

    @discardableResult
    func fetchCategories(uuid: UUID) async -> Result<[Category], Error> {
        let settled = await registry.fetch(uuid: uuid) { [weak self] in
            guard let self else { throw ProviderError.unknown }
            return try await self.fetchAll()
        }

        return settled.loadingState == .error
            ? .failure(settled.error ?? ProviderError.unknown)
            : .success(settled.data)
    }

    func addCategories(_ categories: [Category]) async throws {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.5 ... 1.5)))
        for category in categories {
            categoriesDict[category.id] = category
        }

        // The provider is the sole writer, so re-emitting every registered stream here after
        // appending is what keeps observation live. Future delete/edit paths must also go through
        // the provider and poke the registry, or streams go stale.
        await registry.refetchAll()
    }

    private func fetchAll() async throws -> [Category] {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.5 ... 1.5)))
        return Array(categoriesDict.values)
    }
}
