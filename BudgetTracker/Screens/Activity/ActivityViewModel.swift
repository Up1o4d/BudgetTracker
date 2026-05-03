import Foundation

@Observable
final class ActivityViewModel {
    private let transactionsProvider: any TransactionsProviderProtocol

    init(transactionsProvider: any TransactionsProviderProtocol) {
        self.transactionsProvider = transactionsProvider
    }
}
