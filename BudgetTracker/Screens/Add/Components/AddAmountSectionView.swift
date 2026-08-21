import SwiftUI

struct AddAmountSectionView: View {
    @Binding var amount: Decimal?
    let currencyCode: String

    var body: some View {
        VStack(spacing: 16) {
            Text("AMOUNT") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            CurrencyTextField(amount: $amount, currencyCode: currencyCode)
                .multilineTextAlignment(.center)
                .textStyle(.displayXL)
        }
        .cardBackground()
    }
}

#Preview {
    @Previewable @State var emptyAmount: Decimal?
    @Previewable @State var filledAmount: Decimal? = 1234.56

    VStack(spacing: 16) {
        AddAmountSectionView(amount: $emptyAmount, currencyCode: "USD")
        AddAmountSectionView(amount: $filledAmount, currencyCode: "USD")
    }
    .padding()
}
