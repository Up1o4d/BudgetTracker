import SwiftData

struct AppDependencies {
    let transactionsProvider: TransactionsProviderProtocol
    let categoriesProvider: CategoriesProviderProtocol

    static func inMemory() -> AppDependencies {
        AppDependencies(
            transactionsProvider: InMemoryTransactionsProvider(),
            categoriesProvider: InMemoryCategoriesProvider()
        )
    }

    static func swiftData() throws -> AppDependencies {
        let modelContainer: ModelContainer = try .init(for: StoredTransaction.self, StoredCategory.self)

        return AppDependencies(
            transactionsProvider: SwiftDataTransactionsProvider(modelContainer: modelContainer),
            categoriesProvider: SwiftDataCategoriesProvider(modelContainer: modelContainer)
        )
    }
}
