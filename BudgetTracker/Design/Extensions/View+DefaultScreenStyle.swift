import SwiftUI

extension View {
    /// Applies default styling to a screen
    func defaultScreenStyle() -> some View {
        textStyle(.bodyMD)
            .foregroundStyle(Color.textPrimary)
            .tint(Color.accentLime)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgCanvas.ignoresSafeArea())
    }
}
