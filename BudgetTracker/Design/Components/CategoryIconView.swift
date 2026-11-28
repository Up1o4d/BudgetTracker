import SwiftUI

struct CategoryIconView: View {
    enum Size {
        /// 32pt tile — list rows, chips, the Add sheet.
        case regular
        /// 54pt tile — category detail header.
        case large

        var side: CGFloat {
            switch self {
            case .regular: 32
            case .large: 54
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .regular: 8
            case .large: 16
            }
        }

        /// `nil` inherits the surrounding font.
        var glyphFont: Font? {
            switch self {
            case .regular: nil
            case .large: .system(size: 24)
            }
        }
    }

    @Environment(\.redactionReasons) var redactionReasons

    let category: Category
    var size: Size = .regular

    private var foregroundColor: Color {
        guard redactionReasons.isEmpty else { return Color.borderSubtle }
        return Color(hex: category.colorHex)
    }

    private var iconSystemName: String {
        guard redactionReasons.isEmpty else { return "square.fill" }
        return category.symbolName
    }

    var body: some View {
        RoundedRectangle(cornerRadius: size.cornerRadius)
            .fill(foregroundColor.opacity(0.2))
            .stroke(foregroundColor, lineWidth: 1.0)
            .frame(width: size.side, height: size.side)
            .overlay(
                Image(systemName: iconSystemName)
                    .foregroundStyle(foregroundColor)
                    .if(size.glyphFont != nil) { $0.font(size.glyphFont) }
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

#Preview("Large") {
    VStack {
        ForEach(Category.all) { cat in
            CategoryIconView(category: cat, size: .large)
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
