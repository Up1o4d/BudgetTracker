import SwiftUI

struct AddCategorySectionView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("CATEGORY") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            VStack {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    FlowLayout {
                        ForEach(categories, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Chip(
                                    text: category.name,
                                    systemImage: category.symbolName,
                                    iconColor: Color(hex: category.colorHex),
                                    isSelected: selectedCategory == category
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .cardBackground()
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: Category? = .groceries

    VStack(spacing: 16) {
        AddCategorySectionView(categories: [], selectedCategory: $selectedCategory, isLoading: true)
        AddCategorySectionView(categories: Category.all, selectedCategory: $selectedCategory, isLoading: false)
    }
    .padding()
}
