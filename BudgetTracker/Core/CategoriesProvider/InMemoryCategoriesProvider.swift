import Foundation

actor InMemoryCategoriesProvider: CategoriesProviderProtocol {
    private var categoriesDict: [String: Category]
    private let registry = DataStreamRegistry<Category>()
    private let simulatedLatency: @Sendable () async -> Void

    /// `simulatedLatency` runs before every read and write. Defaults to a random 0.5–1.5s delay so
    /// development builds and previews exercise loading states; tests inject their own to control
    /// ordering deterministically.
    init(
        categories: [Category] = Category.all,
        simulatedLatency: @escaping @Sendable () async -> Void = { try? await Task.sleep(for: .seconds(Double.random(in: 0.5 ... 1.5))) }
    ) {
        categoriesDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        self.simulatedLatency = simulatedLatency
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
        await simulatedLatency()
        for category in categories {
            categoriesDict[category.id] = category
        }

        // The provider is the sole writer, so re-emitting every registered stream here after
        // appending is what keeps observation live. Future delete/edit paths must also go through
        // the provider and poke the registry, or streams go stale.
        await registry.refetchAll()
    }

    private func fetchAll() async throws -> [Category] {
        await simulatedLatency()
        return Array(categoriesDict.values)
    }
}
