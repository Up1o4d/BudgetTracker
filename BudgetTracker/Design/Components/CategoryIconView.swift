import SwiftUI

struct CategoryIconView: View {
    let category: Category

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: category.colorHex).opacity(0.2))
            .stroke(Color(hex: category.colorHex), lineWidth: 1.0)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: category.symbolName)
                    .foregroundStyle(Color(hex: category.colorHex))
            )
    }
}

#Preview {
    VStack {
        ForEach(Category.all) { cat in
            CategoryIconView(category: cat)
        }
    }
}
