import Foundation

@Observable
final class AddViewModel {
    private let transactionsProvider: any TransactionsProviderProtocol
    private let categoriesProvider: any CategoriesProviderProtocol
    private let appSettings: any AppSettingsProtocol

    private var transactionsObserverTask: Task<Void, Never>?
    private var categoriesObserverTask: Task<Void, Never>?
    private var transactionStreamUUID: UUID?
    private var categoryStreamUUID: UUID?

    var transactionsState: DataState<Transaction> = .init()
    var categoriesState: DataState<Category> = .init()

    var amount: Decimal?
    var vendor: String = ""
    var selectedCategory: Category?
    var date: Date = .now

    private(set) var isSaving: Bool = false
    var showErrorAlert: Bool = false

    private let onSaved: (() -> Void)?

    init(
        transactionsProvider: any TransactionsProviderProtocol,
        categoriesProvider: any CategoriesProviderProtocol,
        appSettings: any AppSettingsProtocol,
        onSaved: (() -> Void)? = nil
    ) {
        self.transactionsProvider = transactionsProvider
        self.categoriesProvider = categoriesProvider
        self.appSettings = appSettings
        self.onSaved = onSaved
    }
}

// MARK: - Form state

extension AddViewModel {
    var isFormValid: Bool {
        !vendor.trimmingCharacters(in: .whitespaces).isEmpty && amount != nil && selectedCategory != nil
    }

    var suggestedVendors: [String] {
        var vendorSet: Set<String> = []
        let vendorList = transactionsState.data
            .map { $0.vendor }
            .filter {
                guard !vendorSet.contains($0) else { return false }
                vendorSet.insert($0)
                return true
            }
        return Array(vendorList.prefix(6))
    }

    var quickDateOptions: [QuickDateOption] {
        (0 ... 2).map { offset in QuickDateOption(daysAgo: offset) }
    }

    var currencyCode: String {
        appSettings.currency
    }
}

// MARK: - Saving

extension AddViewModel {
    func save() {
        guard let amount = amount, let selectedCategory = selectedCategory, isFormValid else { return }
        let transaction = Transaction(
            id: UUID().uuidString,
            amount: amount,
            vendor: vendor.trimmingCharacters(in: .whitespaces),
            categoryId: selectedCategory.id,
            date: date
        )

        Task {
            isSaving = true
            do {
                try await transactionsProvider.addTransactions([transaction])
                onSaved?()
            } catch {
                showErrorAlert = true
            }
            isSaving = false
        }
    }
}

// MARK: - Loading

extension AddViewModel {
    @discardableResult
    func loadTransactions() async -> Result<[Transaction], Error> {
        var streamUUID: UUID
        if let transactionStreamUUID {
            streamUUID = transactionStreamUUID
        } else {
            let (task, uuid) = await setUpTransactionsStreamObserver()
            transactionsObserverTask = task
            transactionStreamUUID = uuid
            streamUUID = uuid
        }

        return await transactionsProvider.fetchTransactions(uuid: streamUUID, filter: TransactionFilter())
    }

    @discardableResult
    func loadCategories() async -> Result<[Category], Error> {
        var streamUUID: UUID
        if let categoryStreamUUID {
            streamUUID = categoryStreamUUID
        } else {
            let (task, uuid) = await setUpCategoriesStreamObserver()
            categoriesObserverTask = task
            categoryStreamUUID = uuid
            streamUUID = uuid
        }

        return await categoriesProvider.fetchCategories(uuid: streamUUID)
    }
}

// MARK: - Stream observers

extension AddViewModel {
    func setUpTransactionsStreamObserver() async -> (Task<Void, Never>, UUID) {
        transactionsObserverTask?.cancel()
        let (transactionProviderStream, uuid) = await transactionsProvider.transactionsStream()
        let observerTask = Task { [weak self] in
            guard let self = self else { return }
            for await state in transactionProviderStream {
                if self.isSaving && state.loadingState == .loading { continue }
                self.transactionsState = state
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
