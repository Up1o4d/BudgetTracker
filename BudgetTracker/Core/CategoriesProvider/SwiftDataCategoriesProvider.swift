import Foundation
import SwiftData

actor SwiftDataCategoriesProvider: CategoriesProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)

    private let registry = DataStreamRegistry<Category>()

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
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
        for category in categories {
            modelContext.insert(StoredCategory(category: category))
        }

        try modelContext.save()

        // The provider is the sole writer, so re-emitting every registered stream here after a
        // save is what keeps observation live. Future delete/edit paths must also go through the
        // provider and poke the registry, or streams go stale.
        await registry.refetchAll()
    }

    private func fetchAll() throws -> [Category] {
        let descriptor = FetchDescriptor<StoredCategory>()
        return try modelContext.fetch(descriptor).map(\.asCategory)
    }
}
