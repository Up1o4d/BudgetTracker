import SwiftUI

/// Title + circular close button shown at the top of every modal sheet.
struct SheetHeader: View {
    let title: LocalizedStringKey
    let onClose: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .textStyle(.titleMD)

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.bgSurface)
                            .stroke(Color.borderSubtle, lineWidth: 1)
                    )
            }
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    SheetHeader(title: "screen.add.title", onClose: {})
        .padding(.horizontal, 16)
        .screenDefaults()
}
