import SwiftUI

struct Category: Hashable, Identifiable {
    let id: String
    let name: String
    let symbolName: String // SF Symbol
    let color: Color // TODO: Extract to theme
}

extension Category {
    static let groceries = Category(id: "groceries", name: "Groceries", symbolName: "cart.fill", color: .green)
    static let rent = Category(id: "rent", name: "Rent", symbolName: "house.fill", color: .blue)
    static let transport = Category(id: "transport", name: "Transport", symbolName: "car.fill", color: .orange)
    static let dining = Category(id: "dining", name: "Dining", symbolName: "fork.knife", color: .red)
    static let utilities = Category(id: "utilities", name: "Utilities", symbolName: "bolt.fill", color: .yellow)
    static let other = Category(id: "other", name: "Other", symbolName: "ellipsis.circle", color: .gray)

    static let all: [Category] = [.groceries, .rent, .transport, .dining, .utilities, .other]
}
