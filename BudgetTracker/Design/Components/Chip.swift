import SwiftUI

struct Chip: View {
    let text: String
    var systemImage: String?
    var iconColor: Color = .textSecondary
    var isSelected: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(iconColor)
            }
            Text(text)
                .textStyle(.chip)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .foregroundStyle(Color.textSecondary)
        .background(Capsule().foregroundStyle(Color.bgSurface))
        .overlay(Capsule().stroke(Color.borderSubtle, lineWidth: 1))
        .colorScheme(isSelected ? (colorScheme == .dark ? .light : .dark) : colorScheme)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(Category.all) { category in
            HStack {
                Chip(text: category.name, systemImage: category.symbolName, iconColor: Color(hex: category.colorHex))
                Chip(text: category.name, systemImage: category.symbolName, iconColor: Color(hex: category.colorHex), isSelected: true)
            }
        }
    }
    .padding()
}
