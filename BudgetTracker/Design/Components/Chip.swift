import SwiftUI

struct Chip: View {
    let systemImage: String
    let text: String
    var iconColor: Color = .textSecondary

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundStyle(iconColor)
            Text(text)
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
            Chip(systemImage: category.symbolName, text: category.name, iconColor: Color(hex: category.colorHex))
        }
    }
    .padding()
}
