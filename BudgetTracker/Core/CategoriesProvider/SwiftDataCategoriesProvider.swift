import SwiftData

actor SwiftDataCategoriesProvider: CategoriesProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<StoredCategory>()
        return try modelContext.fetch(descriptor).map(\.asCategory)
    }

    func addCategories(_ categories: [Category]) async throws {
        for category in categories {
            modelContext.insert(StoredCategory(category: category))
        }
        try modelContext.save()
    }
}
