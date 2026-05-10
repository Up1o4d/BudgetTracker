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

    static func swiftData(modelContainer: ModelContainer) -> AppDependencies {
        AppDependencies(
            transactionsProvider: SwiftDataTransactionsProvider(modelContainer: modelContainer),
            categoriesProvider: InMemoryCategoriesProvider() // TODO: replace with SwiftDataCategoriesProvider once that's implemented
        )
    }
}
