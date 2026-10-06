import SwiftUI

struct PercentageBar: View {
    let percentage: Double
    var backgroundBarColor: Color = .borderSubtle
    let foregroundBarColor: Color
    var overflowColor: Color = .statusNegative
    var height: CGFloat = 2.0

    var body: some View {
        Capsule()
            .fill(backgroundBarColor)
            .frame(maxWidth: .infinity, maxHeight: height)
            .overlay {
                GeometryReader { geo in
                    var barWidths: (foregroundWidth: CGFloat, overflowWidth: CGFloat?) {
                        if percentage < 1.0 {
                            return (foregroundWidth: geo.size.width * percentage, overflowWidth: nil)
                        }
                        let overflowShare: Double = percentage - 1.0
                        return (
                            foregroundWidth: (1.0 / percentage) * geo.size.width,
                            overflowWidth: (1.0 / percentage) * overflowShare * geo.size.width
                        )
                    }

                    HStack(spacing: 0.0) {
                        Rectangle()
                            .fill(foregroundBarColor)
                            .frame(width: barWidths.foregroundWidth)
                        if let overflowWidth: CGFloat = barWidths.overflowWidth {
                            Rectangle()
                                .fill(overflowColor)
                                .frame(width: overflowWidth)
                        }
                    }
                    .clipShape(Capsule())
                }
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        PercentageBar(percentage: 0.4, foregroundBarColor: Color.accentLime)
        PercentageBar(percentage: 1.3, foregroundBarColor: Color.accentLime, height: 8.0)
    }
    .padding()
}
