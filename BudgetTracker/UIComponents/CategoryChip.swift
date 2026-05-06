import SwiftUI

struct CategoryChip: View {
    let category: Category

    @Environment(\.colorScheme) private var colorScheme

    // TODO: Extract colors to theme
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "#141416") : .white
    }

    private var borderColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        HStack {
            Image(systemName: category.symbolName)
                .foregroundStyle(category.color)
            Text(category.name)
                .font(.system(size: 12)) // TODO: Extract font to theme or a central place in the project
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .foregroundStyle(textColor)
        .background(Capsule().foregroundStyle(backgroundColor))
        .overlay(Capsule().stroke(borderColor, lineWidth: 0.5))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(Category.all) { category in
            CategoryChip(category: category)
        }
    }
    .padding()
}
