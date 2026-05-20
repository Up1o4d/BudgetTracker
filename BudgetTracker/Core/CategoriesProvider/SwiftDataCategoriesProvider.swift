import Foundation
import SwiftData

actor SwiftDataCategoriesProvider: CategoriesProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)
    private let seededUserDefaultsKey = "categoriesSeeded"

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchCategories() async throws -> [Category] {
        // Seed default categories if this is the first time categories get fetched
        if !UserDefaults.standard.bool(forKey: seededUserDefaultsKey) {
            Category.all.map(StoredCategory.init(category:)).forEach { modelContext.insert($0) }
            try modelContext.save()
            UserDefaults.standard.set(true, forKey: seededUserDefaultsKey)
        }
        let descriptor = FetchDescriptor<StoredCategory>()
        return try modelContext.fetch(descriptor).map(\.asCategory)
    }
}
