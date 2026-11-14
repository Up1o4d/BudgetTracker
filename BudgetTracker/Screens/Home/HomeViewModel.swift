import Foundation

@Observable
final class HomeViewModel {
    private let transactionsProvider: any TransactionsProviderProtocol
    private let categoriesProvider: any CategoriesProviderProtocol
    private let appSettings: any AppSettingsProtocol
    private let router: AppRouter

    private var transactionsObserverTask: Task<Void, Never>?
    private var categoriesObserverTask: Task<Void, Never>?
    private var successfullyFinishedInitialLoad: Bool = false

    private var transactionStreamUUID: UUID?
    private var categoryStreamUUID: UUID?
    private(set) var transactionsState: DataState<Transaction> = .init()
    private(set) var categoriesState: DataState<Category> = .init()

    /// Every month the Home pager can show, oldest first, ending at the current month.
    /// A long finite range rather than a truly infinite one — the pager is lazy, so this is cheap.
    let months: [MonthYear]

    var selectedMonthYear: MonthYear = .current() {
        didSet {
            guard selectedMonthYear != oldValue else { return }
            reloadForSelectedMonth()
        }
    }

    /// Months whose transactions are present in `transactionsState`, as of the latest settled fetch.
    private(set) var loadedMonths: ClosedRange<MonthYear>?
    private var latestTransactionsRequestID = 0
    /// Exposed so tests can await the reload triggered by changing `selectedMonthYear`.
    private(set) var reloadTask: Task<Void, Never>?

    var viewLoadingState: LoadingState {
        guard !successfullyFinishedInitialLoad else { return .idle }
        return LoadingState.merged(transactionsState.loadingState, categoriesState.loadingState)
    }

    var currency: String {
        appSettings.currency
    }

    /// Reads straight through to `appSettings`, which is `@Observable` — views reading this
    /// re-render when the budget changes, without the view model observing anything itself.
    var budget: Decimal? {
        appSettings.budget
    }

    private var categoriesById: [String: Category] {
        Dictionary(uniqueKeysWithValues: categoriesState.data.map { ($0.id, $0) })
    }

    func summary(for month: MonthYear) -> MonthSummary {
        let monthTransactions = transactions(in: month)
        let totalSpending = total(of: monthTransactions)
        return MonthSummary(
            month: month,
            headerText: headerText(for: month),
            totalSpending: totalSpending,
            transactionCount: monthTransactions.count,
            percentageOfBudgetSpent: percentageOfBudgetSpent(totalSpending),
            lastMonthSpendingDiffPercent: lastMonthSpendingDiffPercent(for: month, totalSpending: totalSpending),
            categorySpending: categorySpending(for: monthTransactions, totalSpending: totalSpending),
            dailySpendingSums: dailySpendingSums(for: month, transactions: monthTransactions),
            isLoading: isLoading(month)
        )
    }

    private func percentageOfBudgetSpent(_ totalSpending: Decimal) -> Double {
        guard let budget, budget > 0 else { return 0 }
        return Double(truncating: (totalSpending / budget) as NSNumber)
    }

    private func transactions(in month: MonthYear) -> [Transaction] {
        transactionsState.data.filter { month.monthDateRange.contains($0.date) }
    }

    private func total(of transactions: [Transaction]) -> Decimal {
        transactions.reduce(Decimal.zero) { $0 + $1.amount }
    }

    private func isLoading(_ month: MonthYear) -> Bool {
        guard let loadedMonths else { return true }
        return !(loadedMonths.contains(month) && loadedMonths.contains(month.previousMonth))
    }

    private func headerText(for month: MonthYear) -> String {
        guard month == MonthYear.current() else {
            return month.displayName
        }
        return "\(month.displayName) · \(month.daysRemaining())d left"
    }

    private func lastMonthSpendingDiffPercent(for month: MonthYear, totalSpending: Decimal) -> Double? {
        let totalLastMonthSpending = total(of: transactions(in: month.previousMonth))
        guard totalLastMonthSpending > 0 else { return nil }
        return Double(truncating: (totalSpending / totalLastMonthSpending) as NSNumber) - 1
    }

    private func categorySpending(for transactions: [Transaction], totalSpending: Decimal) -> [CategorySpending] {
        let categoriesById = categoriesById
        let totalsByCategoryId: [String: Decimal] = Dictionary(grouping: transactions, by: \.categoryId)
            .mapValues { transactions in transactions.reduce(Decimal.zero) { $0 + $1.amount } }

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

    private func dailySpendingSums(for month: MonthYear, transactions: [Transaction]) -> [Decimal] {
        var dayCount: Int {
            guard month <= MonthYear.current() else { return 0 }
            guard month == MonthYear.current() else { return month.numberOfDaysInMonth }
            return Calendar.current.component(.day, from: .now)
        }

        var sums = Array(repeating: Decimal.zero, count: dayCount)

        for transaction in transactions {
            let day = Calendar.current.component(.day, from: transaction.date)
            guard day <= dayCount else { continue }
            sums[day - 1] += transaction.amount
        }
        return sums
    }

    init(
        transactionsProvider: any TransactionsProviderProtocol,
        categoriesProvider: any CategoriesProviderProtocol,
        appSettings: any AppSettingsProtocol,
        router: AppRouter
    ) {
        self.transactionsProvider = transactionsProvider
        self.categoriesProvider = categoriesProvider
        self.appSettings = appSettings
        self.router = router
        // ~100 years back, up to and including the current month.
        self.months = MonthYear.range(endingAt: .current(), count: 1201)
    }

    /// Provider streams never finish, so cancel the observers to terminate them and let the
    /// provider deregister them. See "Stream cleanup" in docs/ARCHITECTURE.md.
    isolated deinit {
        transactionsObserverTask?.cancel()
        categoriesObserverTask?.cancel()
        reloadTask?.cancel()
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

        // Fetch the selected month's neighbours too, so pages visible mid-swipe already have data.
        // Each page also needs its own previous month for the month-over-month diff.
        let window = selectedMonthYear.adding(months: -2) ... selectedMonthYear.adding(months: 1)
        latestTransactionsRequestID += 1
        let requestID = latestTransactionsRequestID

        let result = await transactionsProvider.fetchTransactions(
            uuid: streamUUID,
            filter: TransactionFilter(dateRange: window.lowerBound.monthDateRange.lowerBound ... window.upperBound.monthDateRange.upperBound)
        )

        // A newer request supersedes this one; only the latest decides what's loaded.
        if case .success = result, requestID == latestTransactionsRequestID {
            loadedMonths = window
        }
        return result
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

    func editBudgetTapped() {
        router.presentedSheet = .editBudget
    }

    func categoryTapped(_ category: Category, in month: MonthYear) {
        router.push(AppRoute.monthCategorySpending(month: month, category: category), on: .home)
    }

    private func reloadForSelectedMonth() {
        reloadTask?.cancel()
        reloadTask = Task { await self.loadTransactions() }
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
