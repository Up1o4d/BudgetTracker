import SwiftUI

struct Category: Hashable, Identifiable {
    let id: String
    let name: String
    let symbolName: String // SF Symbol
    let color: Color // TODO: Extract to theme
}

extension Category {
    static let groceries = Category(id: "groceries", name: String(localized: "category.groceries"), symbolName: "cart.fill", color: .green)
    static let rent = Category(id: "rent", name: String(localized: "category.rent"), symbolName: "house.fill", color: .blue)
    static let transport = Category(id: "transport", name: String(localized: "category.transport"), symbolName: "car.fill", color: .orange)
    static let dining = Category(id: "dining", name: String(localized: "category.dining"), symbolName: "fork.knife", color: .red)
    static let utilities = Category(id: "utilities", name: String(localized: "category.utilities"), symbolName: "bolt.fill", color: .yellow)
    static let other = Category(id: "other", name: String(localized: "category.other"), symbolName: "ellipsis.circle", color: .gray)

    static let all: [Category] = [.groceries, .rent, .transport, .dining, .utilities, .other]
}
