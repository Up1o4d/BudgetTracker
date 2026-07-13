import Foundation

@Observable
final class AddViewModel {
    enum LoadingState { case initial, loading, idle, error, empty }
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

    private let onSaved: (() -> Void)?

    init(transactionsProvider: any TransactionsProviderProtocol, onSaved: (() -> Void)? = nil) {
        self.transactionsProvider = transactionsProvider
        self.onSaved = onSaved
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
            onSaved?()
            loadingState = .idle
        }
    }
}
