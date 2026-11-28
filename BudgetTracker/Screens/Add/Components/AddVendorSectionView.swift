import SwiftUI

struct AddVendorSectionView: View {
    @Binding var vendor: String
    let suggestedVendors: [String]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading) {
            SectionLabel(leading: "VENDOR") // TODO: Localize
            VStack {
                TextField("Where did you spend?", text: $vendor)
                if isLoading {
                    ProgressView()
                } else {
                    FlowLayout {
                        ForEach(suggestedVendors, id: \.self) { suggestedVendor in
                            Button(action: { vendor = suggestedVendor }) {
                                Chip(text: suggestedVendor, isSelected: vendor == suggestedVendor)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .cardBackground()
        }
    }
}

#Preview {
    @Previewable @State var vendor = "Whole Foods"

    VStack(spacing: 16) {
        AddVendorSectionView(vendor: $vendor, suggestedVendors: [], isLoading: true)
        AddVendorSectionView(vendor: $vendor, suggestedVendors: ["Whole Foods", "Uber", "Netflix"], isLoading: false)
    }
    .padding()
}
