import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = false

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textStyle(.bodyMD)
            .foregroundStyle(isEnabled ? Color.textOnAccent : Color.textTertiary)
            .padding(16)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: 11)
                    .fill(isEnabled ? Color.accentLime : Color.bgSurfaceAlt)
                    .stroke(Color.borderSubtle, lineWidth: isEnabled ? 0 : 1)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("Primary Button") {}
            .buttonStyle(PrimaryButtonStyle())

        Button("Full Width") {}
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))

        Button("Disabled") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
    }
    .padding()
}
