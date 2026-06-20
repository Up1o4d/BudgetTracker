import Foundation

nonisolated struct Category: Hashable, Equatable, Identifiable {
    let id: String
    let name: String
    let symbolName: String
    let colorHex: String
}

nonisolated extension Category {
    static let groceries = Category(id: "groceries", name: String(localized: "category.groceries"), symbolName: "cart.fill", colorHex: "#34C759")
    static let rent = Category(id: "rent", name: String(localized: "category.rent"), symbolName: "house.fill", colorHex: "#007AFF")
    static let transport = Category(id: "transport", name: String(localized: "category.transport"), symbolName: "car.fill", colorHex: "#FF9500")
    static let dining = Category(id: "dining", name: String(localized: "category.dining"), symbolName: "fork.knife", colorHex: "#FF3B30")
    static let utilities = Category(id: "utilities", name: String(localized: "category.utilities"), symbolName: "bolt.fill", colorHex: "#FFCC00")
    static let other = Category(id: "other", name: String(localized: "category.other"), symbolName: "ellipsis.circle", colorHex: "#8E8E93")

    static let unknown = Category(
        id: "unknown",
        name: "Unknown", // TODO: Localize this
        symbolName: "questionmark",
        colorHex: "#FFFFFF"
    )

    static let all: [Category] = [.groceries, .rent, .transport, .dining, .utilities, .other]
}
