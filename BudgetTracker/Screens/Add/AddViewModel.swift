import Foundation

@Observable
final class AddViewModel {
    let transactionsProvider: any TransactionsProviderProtocol

    var loadingState: LoadingState = .idle

    var amountText: String = ""
    var vendor: String = ""
    var selectedCategory: Category = .groceries
    var date: Date = .now

    var isFormValid: Bool {
        !vendor.trimmingCharacters(in: .whitespaces).isEmpty && parsedAmount != nil
    }

    private var parsedAmount: Decimal? {
        guard !amountText.isEmpty,
              let amount = Decimal(string: amountText),
              amount > 0 else { return nil }
        return amount
    }

    init(transactionsProvider: any TransactionsProviderProtocol) {
        self.transactionsProvider = transactionsProvider
    }

    func save() {
        guard let amount = parsedAmount, isFormValid else { return }
        let transaction = Transaction(
            id: UUID().uuidString,
            amount: amount,
            vendor: vendor.trimmingCharacters(in: .whitespaces),
            categoryId: selectedCategory.id,
            date: date
        )

        Task {
            loadingState = .loading
            try? await transactionsProvider.addTransactions([transaction])
            loadingState = .idle
        }
    }
}
