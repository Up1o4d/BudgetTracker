import SwiftUI

extension View {
    /// Applies a text style defined as the `AppTextStyle` struct
    func textStyle(_ style: AppTextStyle) -> some View {
        font(style.font)
            .lineSpacing(style.lineSpacing)
            .tracking(style.tracking)
            .textCase(style.textCase)
    }
}
