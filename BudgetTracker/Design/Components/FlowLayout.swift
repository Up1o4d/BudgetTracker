import SwiftUI

struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let maxWidth = proposal.width ?? .infinity

        var maxRowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentRowWidth > 0 && currentRowWidth + horizontalSpacing + size.width > maxWidth {
                maxRowWidth = max(maxRowWidth, currentRowWidth)
                totalHeight += currentRowHeight + verticalSpacing
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth += (currentRowWidth > 0 ? horizontalSpacing : 0) + size.width
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        maxRowWidth = max(maxRowWidth, currentRowWidth)
        totalHeight += currentRowHeight

        return CGSize(width: maxRowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        let maxWidth = proposal.width ?? .infinity

        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > bounds.minX && x - bounds.minX + horizontalSpacing + size.width > maxWidth {
                x = bounds.minX
                y += currentRowHeight + verticalSpacing
                currentRowHeight = 0
            } else if x > bounds.minX {
                x += horizontalSpacing
            }

            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)

            x += size.width
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}

#Preview("Wrapping") {
    FlowLayout {
        ForEach(Category.all) { category in
            Chip(text: category.name, systemImage: category.symbolName, iconColor: Color(hex: category.colorHex))
        }
    }
    .padding()
    .frame(width: 320)
}

#Preview("Oversized item") {
    FlowLayout {
        Chip(text: "Groceries", systemImage: "cart.fill")
        Chip(text: "A very long category name that overflows the row", systemImage: "text.alignleft")
        Chip(text: "Dining", systemImage: "fork.knife")
    }
    .padding()
    .frame(width: 320)
}
