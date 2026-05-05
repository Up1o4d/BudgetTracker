import SwiftUI

struct CategoryChip: View {
    let category: Category

    var body: some View {
        HStack {
            Image(systemName: category.symbolName)
                .foregroundStyle(category.color)
            Text(category.name)
                .font(.system(size: 12)) // TODO: Extract font to theme or a central place in the project
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .foregroundStyle(.white)
        .background(Capsule().foregroundStyle(Color(hex: "#141416"))) // TODO: Extract color to theme
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
