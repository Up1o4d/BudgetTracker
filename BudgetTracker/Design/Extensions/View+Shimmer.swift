import SwiftUI

/// Animates a diagonal highlight sweep across the view, for use alongside `.redacted(reason: .placeholder)`.
private struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .overlay {
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        let height = proxy.size.height
                        let bandWidth = width * 0.6

                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: Color.shimmerHighlight, location: 0.5),
                                .init(color: .clear, location: 1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: bandWidth, height: height * 2.5)
                        .rotationEffect(.degrees(20))
                        .offset(
                            x: isAnimating ? width + bandWidth : -bandWidth - width,
                            y: -height * 0.75
                        )
                    }
                }
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
        }
    }
}

extension View {
    /// Adds an animated shimmer sweep, intended to be layered on top of `.redacted(reason: .placeholder)`.
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
