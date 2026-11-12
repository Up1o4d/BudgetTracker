import Charts
import SwiftUI

struct SpendingLineChart: View {
    private let values: [Decimal]
    private let color: Color
    private let xMin: Int
    private let xMax: Int

    init(values: [Decimal], color: Color, xMin: Int = 1, xMax: Int) {
        precondition(xMin <= xMax, "SpendingLineChart: xMin (\(xMin)) must be <= xMax (\(xMax))")
        self.values = values
        self.color = color
        self.xMin = xMin
        self.xMax = xMax
    }

    private var linearGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    color.opacity(0.4),
                    color.opacity(0),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        Chart {
            ForEach(values.enumerated(), id: \.offset) { inx, value in
                LineMark(x: .value("X", xMin + inx),
                         y: .value("Value", value))
                    .foregroundStyle(color)

                AreaMark(x: .value("X", xMin + inx),
                         y: .value("Value", value))
                    .foregroundStyle(linearGradient)
            }
        }
        .chartXScale(domain: xMin ... xMax)
    }
}

#Preview("Loaded") {
    let values: [Decimal] = [
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        12.99, 34.55, 99.12, 34.55, 289.20, 599.10, 9.11,
        12.99, 34.55, 99.12, 34.55, 0.00, 499.10, 10.0,
    ]
    SpendingLineChart(values: values, color: .accentLime, xMax: 31)
        .frame(height: 150)
        .padding()
}

#Preview("Empty") {
    SpendingLineChart(values: [], color: .accentLime, xMax: 31)
        .frame(height: 150)
        .padding()
}

#Preview("Custom xMin") {
    let values: [Decimal] = [12.99, 34.55, 99.12, 34.55, 289.20, 599.10, 9.11]
    SpendingLineChart(values: values, color: .accentLime, xMin: 10, xMax: 20)
        .frame(height: 150)
        .padding()
}
