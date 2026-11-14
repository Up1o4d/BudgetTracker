import Foundation

/// Transactions for a single category within a single month, kept live via the provider stream.
@Observable
final class MonthCategorySpendingViewModel {
    let month: MonthYear
    let category: Category

    private let transactionsProvider: any TransactionsProviderProtocol
    private let appSettings: any AppSettingsProtocol

    private var transactionsObserverTask: Task<Void, Never>?
    private var transactionStreamUUID: UUID?
    private var successfullyFinishedInitialLoad: Bool = false
    private(set) var transactionsState: DataState<Transaction> = .init()

    var viewLoadingState: LoadingState {
        guard !successfullyFinishedInitialLoad else { return .idle }
        return transactionsState.loadingState
    }

    /// Newest first.
    var transactions: [Transaction] {
        transactionsState.data.sorted { $0.date > $1.date }
    }

    var totalAmount: Decimal {
        transactionsState.data.reduce(Decimal.zero) { $0 + $1.amount }
    }

    var currency: String {
        appSettings.currency
    }

    var title: String {
        "\(category.name) · \(month.displayName)"
    }

    init(
        month: MonthYear,
        category: Category,
        transactionsProvider: any TransactionsProviderProtocol,
        appSettings: any AppSettingsProtocol
    ) {
        self.month = month
        self.category = category
        self.transactionsProvider = transactionsProvider
        self.appSettings = appSettings
    }

    /// Provider streams never finish, so cancel the observer to terminate it and let the
    /// provider deregister it. See "Stream cleanup" in docs/ARCHITECTURE.md.
    isolated deinit {
        transactionsObserverTask?.cancel()
    }

    func loadData() async {
        let streamUUID: UUID
        if let transactionStreamUUID {
            streamUUID = transactionStreamUUID
        } else {
            let (task, uuid) = await setUpTransactionsStreamObserver()
            transactionsObserverTask = task
            transactionStreamUUID = uuid
            streamUUID = uuid
        }

        let result = await transactionsProvider.fetchTransactions(
            uuid: streamUUID,
            filter: TransactionFilter(categoryIds: [category.id], dateRange: month.monthDateRange)
        )

        // Decide from the awaited result, not `transactionsState`, which the observer updates
        // asynchronously and may not have drained yet.
        if case .success = result {
            successfullyFinishedInitialLoad = true
        }
    }
}

// MARK: - Observers

extension MonthCategorySpendingViewModel {
    func setUpTransactionsStreamObserver() async -> (Task<Void, Never>, UUID) {
        transactionsObserverTask?.cancel()
        let (transactionProviderStream, uuid) = await transactionsProvider.transactionsStream()
        let observerTask = Task { [weak self] in
            for await state in transactionProviderStream {
                self?.transactionsState = state
            }
        }

        return (observerTask, uuid)
    }
}
