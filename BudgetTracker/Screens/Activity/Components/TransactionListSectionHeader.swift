import SwiftUI

struct TransactionListSectionHeader: View {
    let date: Date
    let moneySpent: Decimal
    let currency: String

    var body: some View {
        HStack {
            Text(date.formatted("EEE, dd. MMM yyyy"))
                .foregroundStyle(Color.textTertiary)
            Spacer()
            Text(
                moneySpent,
                format: .currency(code: currency)
            )
            .foregroundStyle(Color.textSecondary)
        }
        .textStyle(.eyebrow)
    }
}

#Preview {
    VStack {
        TransactionListSectionHeader(
            date: Date(),
            moneySpent: 500,
            currency: "USD"
        )
        TransactionListSectionHeader(
            date: Date().addingTimeInterval(-86400),
            moneySpent: 128.40,
            currency: "EUR"
        )
    }
    .padding()
}
