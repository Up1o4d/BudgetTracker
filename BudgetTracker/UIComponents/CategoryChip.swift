import SwiftUI

struct CategoryChip: View {
    let category: Category

    var body: some View {
        HStack {
            Image(systemName: category.symbolName)
                .foregroundStyle(category.color)
            Text(category.name)
                .textStyle(.chip)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .foregroundStyle(Color.textSecondary)
        .background(Capsule().foregroundStyle(Color.bgSurface))
        .overlay(Capsule().stroke(Color.borderSubtle, lineWidth: 1))
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
