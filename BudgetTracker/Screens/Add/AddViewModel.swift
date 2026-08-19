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
    private(set) var transactionsState: DataState<Transaction> = .init()
    private(set) var categoriesState: DataState<Category> = .init()

    var amount: Decimal?
    var vendor: String = ""
    var selectedCategory: Category?
    var date: Date = .now

    private(set) var isSaving: Bool = false
    var isFormValid: Bool {
        !vendor.trimmingCharacters(in: .whitespaces).isEmpty && amount != nil
    }

    var sugestedVendors: [String] {
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

    var currencyCode: String {
        appSettings.currency
    }

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
            try? await transactionsProvider.addTransactions([transaction])
            onSaved?()
            isSaving = false
        }
    }

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

// MARK: - Date quick options

extension AddViewModel {
    typealias QuickDateOption = (label: String, daysAgo: Int)

    var quickDateOptions: [QuickDateOption] {
        (0 ... 2).map { offset in (label: quickDateLabel(daysAgo: offset), daysAgo: offset) }
    }

    func quickDateLabel(daysAgo: Int) -> String {
        switch daysAgo {
        case 0: String(localized: "screen.add.date.today")
        case 1: String(localized: "screen.add.date.yesterday")
        default: String(localized: "screen.add.date.daysAgo", defaultValue: "\(daysAgo) days ago")
        }
    }

    private func quickDateOptionToDate(_ option: QuickDateOption) -> Date {
        return Calendar.current.date(byAdding: .day, value: -option.daysAgo, to: .now) ?? .now
    }

    func selectQuickDateOption(_ option: QuickDateOption) {
        date = quickDateOptionToDate(option)
    }

    func quickDateOptionIsSelected(_ option: QuickDateOption) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: quickDateOptionToDate(option))
    }
}

extension AddViewModel {
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
