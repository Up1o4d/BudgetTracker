import SwiftUI

struct CategoryIconView: View {
    @Environment(\.redactionReasons) var redactionReasons

    let category: Category

    private var foregroundColor: Color {
        guard redactionReasons.isEmpty else { return Color.borderSubtle }
        return Color(hex: category.colorHex)
    }

    private var iconSystemName: String {
        guard redactionReasons.isEmpty else { return "square.fill" }
        return category.symbolName
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(foregroundColor.opacity(0.2))
            .stroke(foregroundColor, lineWidth: 1.0)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: iconSystemName)
                    .foregroundStyle(foregroundColor)
            )
    }
}

#Preview("Normal") {
    VStack {
        ForEach(Category.all) { cat in
            CategoryIconView(category: cat)
        }
    }
}

#Preview("Redacted") {
    VStack {
        ForEach(Category.all) { cat in
            CategoryIconView(category: cat)
        }
    }
    .redacted(reason: .placeholder)
}
