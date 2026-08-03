import Foundation

@Observable
final class AddViewModel {
    enum LoadingState { case initial, loading, idle, error, empty }
    let transactionsProvider: any TransactionsProviderProtocol
    private let appSettings: any AppSettingsProtocol

    var loadingState: LoadingState = .idle

    var amount: Decimal?

    var vendor: String = ""
    var selectedCategory: Category = .groceries
    var date: Date = .now

    var isFormValid: Bool {
        !vendor.trimmingCharacters(in: .whitespaces).isEmpty && amount != nil
    }

    private let onSaved: (() -> Void)?

    init(
        transactionsProvider: any TransactionsProviderProtocol,
        appSettings: any AppSettingsProtocol,
        onSaved: (() -> Void)? = nil
    ) {
        self.transactionsProvider = transactionsProvider
        self.appSettings = appSettings
        self.onSaved = onSaved
    }

    var currencyCode: String {
        appSettings.currency
    }

    func save() {
        guard let amount = amount, isFormValid else { return }
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
