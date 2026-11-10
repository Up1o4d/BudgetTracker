import SwiftUI

extension View {
    /// Applies default styling and behavior to a screen
    func screenDefaults() -> some View {
        textStyle(.bodyMD)
            .foregroundStyle(Color.textPrimary)
            .tint(Color.accentLime)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgCanvas.ignoresSafeArea())
            .dismissesKeyboardOnBackgroundTap()
    }
}
