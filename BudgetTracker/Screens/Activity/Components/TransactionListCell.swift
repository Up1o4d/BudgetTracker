import SwiftUI

struct TransactionListCell: View {
    let transaction: Transaction
    let category: Category
    let currency: String

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: category.colorHex).opacity(0.2))
                .stroke(Color(hex: category.colorHex), lineWidth: 1.0)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: category.symbolName)
                        .foregroundStyle(Color(hex: category.colorHex))
                )

            VStack(alignment: .leading) {
                Text(transaction.vendor)
                Text(category.name)
                    .textStyle(.metadata)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Text(
                transaction.amount,
                format: .currency(code: currency)
            )
            .textStyle(.bodyMDSemibold)
        }
        .textStyle(.bodyMD)
    }
}

#Preview {
    let transactionCategories: [(Transaction, Category)] = [
        (
            Transaction(
                id: "1",
                amount: 1200.00,
                vendor: "City Apartments",
                categoryId: Category.rent.id,
                date: Date()
            ),
            Category.rent
        ),
        (
            Transaction(
                id: "2",
                amount: 54.30,
                vendor: "Whole Foods",
                categoryId: Category.groceries.id,
                date: Date()
            ),
            Category.groceries
        ),
        (
            Transaction(
                id: "3",
                amount: 12.50,
                vendor: "Uber",
                categoryId: Category.transport.id,
                date: Date()
            ),
            Category.transport
        ),
        (
            Transaction(
                id: "4",
                amount: 38.75,
                vendor: "The Italian Place",
                categoryId: Category.dining.id,
                date: Date()
            ),
            Category.dining
        ),
    ]

    return VStack {
        ForEach(transactionCategories, id: \.0) { transactionCategory in
            TransactionListCell(
                transaction: transactionCategory.0,
                category: transactionCategory.1,
                currency: "USD"
            )
        }
    }
}
