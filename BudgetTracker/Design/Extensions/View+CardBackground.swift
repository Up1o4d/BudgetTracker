import SwiftUI

extension View {
    /// Applies the standard surface-card background used by grouped content sections.
    func cardBackground() -> some View {
        padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.bgSurface)
                    .stroke(Color.borderSubtle, lineWidth: 1)
            )
    }
}
