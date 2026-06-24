import SwiftUI

struct AppTextField: View {
    let iconSystemName: String?
    let placeholderText: String
    @Binding var text: String

    init(iconSystemName: String? = nil, placeholderText: String, text: Binding<String>) {
        self.iconSystemName = iconSystemName
        self.placeholderText = placeholderText
        _text = text
    }

    var body: some View {
        HStack(spacing: 16) {
            if let iconSystemName = iconSystemName {
                let iconSize: CGFloat = 18
                Image(systemName: iconSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }
            TextField(placeholderText, text: $text)
        }
        .frame(height: 18)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgSurface)
                .stroke(Color.borderSubtle, lineWidth: 1)
                .padding(2)
        }
        .textStyle(.bodyMD)
        .foregroundStyle(Color.textSecondary)
    }
}

#Preview {
    VStack {
        Spacer()
        AppTextField(iconSystemName: "magnifyingglass", placeholderText: "Lorem Ipsum", text: .constant(""))
        Spacer()
        AppTextField(placeholderText: "Lorem Ipsum", text: .constant(""))
        Spacer()
        AppTextField(iconSystemName: "magnifyingglass", placeholderText: "Lorem Ipsum", text: .constant("Inserted text"))
        Spacer()
    }
}
