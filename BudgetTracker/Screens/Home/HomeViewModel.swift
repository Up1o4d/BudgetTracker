import Foundation

@Observable
final class HomeViewModel {
    typealias CategorySpending = (category: Category, totalAmount: Decimal, percentageOfTotal: Double, roundedPercentage: Int)

    private let transactionsProvider: any TransactionsProviderProtocol
    private let categoriesProvider: any CategoriesProviderProtocol
    private let appSettings: any AppSettingsProtocol

    private var transactionsObserverTask: Task<Void, Never>?
    private var categoriesObserverTask: Task<Void, Never>?
    private var successfullyFinishedInitialLoad: Bool = false

    private var transactionStreamUUID: UUID?
    private var categoryStreamUUID: UUID?
    private(set) var transactionsState: DataState<Transaction> = .init()
    private(set) var categoriesState: DataState<Category> = .init()

    private(set) var selectedMonth: Int = Calendar.current.component(.month, from: .now)
    private(set) var selectedYear: Int = Calendar.current.component(.year, from: .now)

    var viewLoadingState: LoadingState {
        guard !successfullyFinishedInitialLoad else { return .idle }
        return LoadingState.merged(transactionsState.loadingState, categoriesState.loadingState)
    }

    var currency: String {
        appSettings.currency
    }

    private var categoriesById: [String: Category] {
        Dictionary(uniqueKeysWithValues: categoriesState.data.map { ($0.id, $0) })
    }

    private var selectedMonthDateRange: ClosedRange<Date> {
        dateRange(forMonth: selectedMonth, year: selectedYear)
    }

    private var previousMonthDateRange: ClosedRange<Date> {
        let previous = previousMonth(before: selectedMonth, year: selectedYear)
        return dateRange(forMonth: previous.month, year: previous.year)
    }

    var categorySpending: [CategorySpending] {
        let currentMonthTransactions = transactionsState.data.filter { selectedMonthDateRange.contains($0.date) }
        let totalsByCategoryId: [String: Decimal] = Dictionary(grouping: currentMonthTransactions, by: \.categoryId)
            .mapValues { transactions in transactions.reduce(Decimal.zero) { $0 + $1.amount } }

        let totalSpending: Decimal = totalsByCategoryId.values.reduce(Decimal.zero, +)
        var cumulPercentage: Double = 0

        return totalsByCategoryId
            .sorted {
                // Sort by total amount.
                // Important we do this before calculating roundedPercentage,
                // because there can be minor variation of roundedPercentage based on the order,
                // which can mess with snapshot tests
                $0.value > $1.value
            }
            .map { categoryId, totalAmount in
                let category: Category = categoriesById[categoryId] ?? Category.unknown
                let percentage = totalSpending.isZero ? 0 : Double(truncating: (totalAmount / totalSpending) as NSNumber)
                let prevRoundedPercentage: Double = cumulPercentage.rounded()
                cumulPercentage += (percentage * 100)
                let currRoundedPercentage: Double = cumulPercentage.rounded()
                let roundedPercent = Int(currRoundedPercentage - prevRoundedPercentage)
                return CategorySpending(
                    category: category,
                    totalAmount: totalAmount,
                    percentageOfTotal: percentage,
                    roundedPercentage: roundedPercent
                )
            }
    }

    var maxCategorySpending: CategorySpending? {
        categorySpending.first
    }

    var previousMonthTotalSpending: Decimal {
        transactionsState.data
            .filter { previousMonthDateRange.contains($0.date) }
            .reduce(Decimal.zero) { $0 + $1.amount }
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

        return await transactionsProvider.fetchTransactions(
            uuid: streamUUID,
            filter: TransactionFilter(dateRange: previousMonthDateRange.lowerBound ... selectedMonthDateRange.upperBound)
        )
    }

    /// Bounded to the whole month, not capped at "now" — so a transaction added later in the
    /// month still matches without the VM needing to recompute the range.
    private func dateRange(forMonth month: Int, year: Int, calendar: Calendar = .current) -> ClosedRange<Date> {
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month)) ?? .now
        let interval = calendar.dateInterval(of: .month, for: startOfMonth) ?? DateInterval(start: startOfMonth, end: startOfMonth)
        return interval.start ... interval.end
    }

    private func previousMonth(before month: Int, year: Int) -> (month: Int, year: Int) {
        month == 1 ? (12, year - 1) : (month - 1, year)
    }

    private func nextMonth(after month: Int, year: Int) -> (month: Int, year: Int) {
        month == 12 ? (1, year + 1) : (month + 1, year)
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

    /// Returned so tests can await completion; production callers discard it.
    @discardableResult
    func selectNextMonth() -> Task<Void, Never> {
        let next = nextMonth(after: selectedMonth, year: selectedYear)
        selectedMonth = next.month
        selectedYear = next.year
        return Task { await self.loadTransactions() }
    }

    @discardableResult
    func selectPreviousMonth() -> Task<Void, Never> {
        let previous = previousMonth(before: selectedMonth, year: selectedYear)
        selectedMonth = previous.month
        selectedYear = previous.year
        return Task { await self.loadTransactions() }
    }
}

// MARK: - Observers

extension HomeViewModel {
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
