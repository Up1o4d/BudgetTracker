import Foundation
import SwiftData

@Model
class StoredCategory {
    var id: String
    var name: String
    var symbolName: String
    var colorHex: String

    init(id: String, name: String, symbolName: String, colorHex: String) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.colorHex = colorHex
    }

    convenience init(category: Category) {
        self.init(id: category.id, name: category.name,
                  symbolName: category.symbolName, colorHex: category.colorHex)
    }

    var asCategory: Category {
        Category(id: id, name: name, symbolName: symbolName, colorHex: colorHex)
    }
}
