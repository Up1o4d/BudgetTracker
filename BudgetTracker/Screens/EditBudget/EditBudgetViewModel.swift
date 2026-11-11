import Foundation

@Observable
final class EditBudgetViewModel {
    private let appSettings: any AppSettingsProtocol
    private let onSaved: (() -> Void)?

    /// Draft value — only written to `appSettings` on `save()`, so dismissing discards it.
    var amount: Decimal?

    init(appSettings: any AppSettingsProtocol, onSaved: (() -> Void)? = nil) {
        self.appSettings = appSettings
        self.onSaved = onSaved
        amount = appSettings.budget
    }

    var currencyCode: String {
        appSettings.currency
    }

    var isValid: Bool {
        guard let amount else { return false }
        return amount > 0
    }

    func save() {
        guard isValid else { return }
        appSettings.budget = amount
        onSaved?()
    }
}
