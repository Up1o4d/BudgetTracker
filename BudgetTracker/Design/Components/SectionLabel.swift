import SwiftUI

/// Eyebrow row shown above a section: leading title + optional trailing detail.
struct SectionLabel: View {
    let leading: String
    var trailing: String? = nil

    var body: some View {
        HStack {
            Text(leading)
                .foregroundStyle(Color.textTertiary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .textStyle(.eyebrow)
    }
}

#Preview {
    VStack(spacing: 16) {
        SectionLabel(leading: "November 2026", trailing: "52 TXNS")
        SectionLabel(leading: "By category")
    }
    .padding()
    .screenDefaults()
}
