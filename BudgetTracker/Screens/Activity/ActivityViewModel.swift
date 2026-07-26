import Foundation

@Observable
final class ActivityViewModel {
    typealias TransactionCategory = (transaction: Transaction, category: Category)

    private let transactionsProvider: any TransactionsProviderProtocol
    private let categoriesProvider: any CategoriesProviderProtocol
    private let appSettings: any AppSettingsProtocol

    private var transactionsObserverTask: Task<Void, Never>?
    private var categoriesObserverTask: Task<Void, Never>?
    private var successfullyFinishedInitialLoad: Bool = false
    private var searchTask: Task<Void, Never>?

    private var transactionStreamUUID: UUID?
    private var categoryStreamUUID: UUID?
    private(set) var transactionsState: DataState<Transaction> = .init()
    private(set) var categoriesState: DataState<Category> = .init()

    private(set) var filterCategoryIds: Set<String> = []

    var searchString: String = "" {
        didSet {
            guard searchString != oldValue else { return }
            searchTask?.cancel()
            searchTask = Task {
                do {
                    try await Task.sleep(for: .milliseconds(300))
                    await loadTransactions()
                } catch {}
            }
        }
    }

    var viewLoadingState: LoadingState {
        guard !successfullyFinishedInitialLoad else { return .idle }
        return LoadingState.merged(transactionsState.loadingState, categoriesState.loadingState)
    }

    private var categoriesById: [String: Category] {
        Dictionary(uniqueKeysWithValues: categoriesState.data.map { ($0.id, $0) })
    }

    private var transactionCategories: [TransactionCategory] {
        return transactionsState.data.map {
            (
                transaction: $0,
                category: categoriesById[$0.categoryId] ?? Category.unknown
            )
        }
    }

    var transactionCategoriesByDate: [Date: [TransactionCategory]] {
        Dictionary(grouping: transactionCategories, by: { Calendar.current.startOfDay(for: $0.transaction.date) })
    }

    var currency: String {
        appSettings.currency
    }

    init(
        transactionsProvider: any TransactionsProviderProtocol,
        categoriesProvider: any CategoriesProviderProtocol,
        appSettings: any AppSettingsProtocol
    ) {
        self.transactionsProvider = transactionsProvider
        self.categoriesProvider = categoriesProvider
        self.appSettings = appSettings
    }

    /// Returns the fetch's settled result so `loadData` can decide whether the initial load
    /// succeeded from the value it awaits directly, rather than from `transactionsState`, which
    /// the stream observer updates asynchronously and may not have drained yet.
    @discardableResult
    private func loadTransactions() async -> Result<[Transaction], Error> {
        var streamUUID: UUID
        if let transactionStreamUUID = transactionStreamUUID {
            streamUUID = transactionStreamUUID
        } else {
            // transactionStreamUUID is nil, need to set up the observer first
            let (task, uuid) = await setUpTransactionsStreamObserver()
            transactionsObserverTask = task
            transactionStreamUUID = uuid
            streamUUID = uuid
        }

        var transactionFilter: TransactionFilter {
            TransactionFilter(
                categoryIds: filterCategoryIds.isEmpty ? nil : filterCategoryIds,
                vendorSubstring: searchString.isEmpty ? nil : searchString
            )
        }

        return await transactionsProvider.fetchTransactions(
            uuid: streamUUID,
            filter: transactionFilter
        )
    }

    @discardableResult
    private func loadCategories() async -> Result<[Category], Error> {
        var streamUUID: UUID
        if let categoryStreamUUID = categoryStreamUUID {
            streamUUID = categoryStreamUUID
        } else {
            // categoryStreamUUID is nil, need to set up the observer first
            let (task, uuid) = await setUpCategoriesStreamObserver()
            categoriesObserverTask = task
            categoryStreamUUID = uuid
            streamUUID = uuid
        }

        return await categoriesProvider.fetchCategories(uuid: streamUUID)
    }

    func loadData() async {
        async let transactionsResult = loadTransactions()
        async let categoriesResult = loadCategories()
        let (transactions, categories) = await (transactionsResult, categoriesResult)

        // Decide "initial load finished" from the awaited fetch results — not from
        // `viewLoadingState` or the state properties, which the stream observers update
        // asynchronously and may not have drained yet.
        if case .success = transactions, case .success = categories {
            successfullyFinishedInitialLoad = true
        }
    }

    func calculateMoneySpent(on date: Date) -> Decimal {
        guard let transactions = transactionCategoriesByDate[date] else { return 0 }
        return transactions.reduce(0) { partialResult, transactionCategory in
            partialResult + transactionCategory.transaction.amount
        }
    }

    /// Returned so tests can await completion; production callers discard it.
    @discardableResult
    func toggleFilterCategory(_ category: Category) -> Task<Void, Never> {
        if filterCategoryIds.contains(category.id) {
            filterCategoryIds.remove(category.id)
        } else {
            filterCategoryIds.insert(category.id)
        }
        return Task { await self.loadTransactions() }
    }

    @discardableResult
    func resetFilterCategories() -> Task<Void, Never> {
        filterCategoryIds.removeAll()
        return Task { await self.loadTransactions() }
    }
}

// MARK: - Observers

extension ActivityViewModel {
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

    func setUpCategoriesStreamObserver() async -> (Task<Void, Never>, UUID) {
        categoriesObserverTask?.cancel()
        let (categoryProviderStream, uuid) = await categoriesProvider.categoriesStream()
        let observerTask = Task { [weak self] in
            for await state in categoryProviderStream {
                self?.categoriesState = state
            }
        }

        return (observerTask, uuid)
    }
}
