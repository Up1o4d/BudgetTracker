import SwiftUI

struct CategoryChip: View {
    let category: Category

    var body: some View {
        HStack {
            Image(systemName: category.symbolName)
                .foregroundStyle(category.color)
            Text(category.name)
                .font(.system(size: 12))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .foregroundStyle(.white)
        .background(Capsule().foregroundStyle(Color(hex: "#141416")))
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
