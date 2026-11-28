import SwiftUI

extension View {
    /// Applies the standard surface-card background used by grouped content sections.
    ///
    /// Pass a `tint` (e.g. a category color) to give the card a toned-down border and a faint
    /// gradient wash in that color. The tint is ignored while the view is redacted.
    func cardBackground(tint: Color? = nil) -> some View {
        modifier(CardBackgroundModifier(tint: tint))
    }
}

private struct CardBackgroundModifier: ViewModifier {
    private static let cornerRadius: CGFloat = 20
    private static let tintBorderOpacity = 0.27
    private static let tintGradientOpacity = 0.07
    private static let tintGradientFadeEnd = 0.7

    @Environment(\.redactionReasons) private var redactionReasons

    let tint: Color?

    private var activeTint: Color? {
        redactionReasons.isEmpty ? tint : nil
    }

    private var borderColor: Color {
        activeTint?.opacity(Self.tintBorderOpacity) ?? .borderSubtle
    }

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: Self.cornerRadius)
        content
            .padding(16)
            .background {
                ZStack {
                    shape.fill(Color.bgSurface)
                    if let activeTint {
                        shape.fill(
                            LinearGradient(
                                stops: [
                                    .init(color: activeTint.opacity(Self.tintGradientOpacity), location: 0),
                                    .init(color: activeTint.opacity(0), location: Self.tintGradientFadeEnd),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    shape.stroke(borderColor, lineWidth: 1)
                }
            }
    }
}
