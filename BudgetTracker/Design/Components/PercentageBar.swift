import SwiftUI

struct PercentageBar: View {
    @Environment(\.redactionReasons) var redactionReasons

    let percentage: Double
    var backgroundBarColor: Color = .borderSubtle
    let foregroundBarColor: Color
    var overflowColor: Color = .statusNegative
    var height: CGFloat = 2.0

    private var redactedPercentage: Double {
        guard redactionReasons.isEmpty else { return 0 }
        return percentage
    }

    var body: some View {
        Capsule()
            .fill(backgroundBarColor)
            .frame(maxWidth: .infinity, maxHeight: height)
            .overlay {
                GeometryReader { geo in
                    var barWidths: (foregroundWidth: CGFloat, overflowWidth: CGFloat?) {
                        if redactedPercentage < 1.0 {
                            return (foregroundWidth: geo.size.width * redactedPercentage, overflowWidth: nil)
                        }
                        let overflowShare: Double = redactedPercentage - 1.0
                        return (
                            foregroundWidth: (1.0 / redactedPercentage) * geo.size.width,
                            overflowWidth: (1.0 / redactedPercentage) * overflowShare * geo.size.width
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

#Preview("Normal") {
    VStack(spacing: 16) {
        PercentageBar(percentage: 0.4, foregroundBarColor: Color.accentLime)
        PercentageBar(percentage: 1.3, foregroundBarColor: Color.accentLime, height: 8.0)
    }
    .padding()
}

#Preview("Redacted") {
    VStack(spacing: 16) {
        PercentageBar(percentage: 0.4, foregroundBarColor: Color.accentLime)
        PercentageBar(percentage: 1.3, foregroundBarColor: Color.accentLime, height: 8.0)
    }
    .padding()
    .redacted(reason: .placeholder)
}
