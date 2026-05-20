import Foundation
import SwiftData

actor SwiftDataCategoriesProvider: CategoriesProviderProtocol {
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = .init(modelContainer)

    // Needs to be nonisolated so that we can set it and inject it in MainActor init for unit test purposes.
    // Will never get accessed across actor boundries otherwise so this is safe
    private nonisolated(unsafe) let userDefaults: UserDefaults
    private let seededUserDefaultsKey = "categoriesSeeded"

    init(modelContainer: ModelContainer, userDefaults: UserDefaults = .standard) {
        self.modelContainer = modelContainer
        self.userDefaults = userDefaults
    }

    func fetchCategories() async throws -> [Category] {
        if !userDefaults.bool(forKey: seededUserDefaultsKey) {
            Category.all.map(StoredCategory.init(category:)).forEach { modelContext.insert($0) }
            try modelContext.save()
            userDefaults.set(true, forKey: seededUserDefaultsKey)
        }
        let descriptor = FetchDescriptor<StoredCategory>()
        return try modelContext.fetch(descriptor).map(\.asCategory)
    }
}
