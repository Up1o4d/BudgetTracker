import SwiftUI

struct TransactionListSectionHeader: View {
    let date: Date
    let moneySpent: Decimal
    let currency: String

    var body: some View {
        SectionLabel(
            leading: date.formatted("EEE, dd. MMM yyyy"),
            trailing: moneySpent.formatted(.currency(code: currency))
        )
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
