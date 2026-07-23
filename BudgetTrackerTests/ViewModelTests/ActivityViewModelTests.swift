@testable import BudgetTracker
import Foundation
import Testing

struct ActivityViewModelTests {
    let transactionsProvider: MockTransactionsProvider
    let categoriesProvider: MockCategoriesProvider
    let sut: ActivityViewModel

    init() {
        transactionsProvider = MockTransactionsProvider()
        categoriesProvider = MockCategoriesProvider()
        sut = ActivityViewModel(transactionsProvider: transactionsProvider, categoriesProvider: categoriesProvider, appSettings: InMemoryAppSettings())
    }

    /// The ViewModel applies transaction stream emissions on a detached observer `Task`, so a
    /// settled state pushed by `fetchTransactions`/`addTransactions` lands on `transactionsState`
    /// one hop after the awaited call returns. Polls until `condition` holds rather than sleeping a
    /// fixed interval — the latter flakes under Swift Testing's parallel execution, where the
    /// observer Task can be scheduled well after any fixed delay.
    private func waitUntil(_ condition: () -> Bool, timeout: Duration = .seconds(2)) async {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while !condition(), ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    // MARK: - Initial state

    @Test
    func initialState() {
        #expect(sut.viewLoadingState == .loading)
        #expect(sut.transactionsState.data.isEmpty)
        #expect(sut.categoriesState.data.isEmpty)
    }

    // MARK: - loadData() happy path

    @Test
    func loadData_setsIdleStateWhenTransactionsNonEmpty() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        await sut.loadData()
        await waitUntil { sut.viewLoadingState == .idle }
        #expect(sut.viewLoadingState == .idle)
    }

    @Test
    func loadData_setsIdleStateWhenNoTransactions() async {
        await sut.loadData()
        await waitUntil { sut.viewLoadingState == .idle }
        #expect(sut.viewLoadingState == .idle)
    }

    @Test
    func loadData_populatesTransactions() async {
        let transactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        transactionsProvider.stubbedTransactions = transactions
        await sut.loadData()
        await waitUntil { sut.transactionsState.data == transactions }
        #expect(sut.transactionsState.data == transactions)
    }

    @Test
    func loadData_populatesCategories() async {
        let categories: [BudgetTracker.Category] = [.groceries, .dining]
        categoriesProvider.stubbedCategories = categories
        await sut.loadData()
        #expect(sut.categoriesState.data == categories)
    }

    @Test
    func loadData_callsProvidersOnce() async {
        await sut.loadData()
        #expect(transactionsProvider.transactionsStreamCallCount == 1)
        #expect(categoriesProvider.fetchCategoriesCallCount == 1)
    }

    // MARK: - loadData() error path

    @Test
    func loadData_setsErrorStateOnTransactionsFailure() async {
        transactionsProvider.stubbedError = NSError(domain: "test", code: 0)
        await sut.loadData()
        await waitUntil { sut.viewLoadingState == .error }
        #expect(sut.viewLoadingState == .error)
    }

    @Test
    func loadData_setsErrorStateOnCategoriesFailure() async {
        categoriesProvider.stubbedError = NSError(domain: "test", code: 0)
        await sut.loadData()
        await waitUntil { sut.viewLoadingState == .error }
        #expect(sut.viewLoadingState == .error)
    }

    // MARK: - toggleFilterCategory

    @Test
    func toggleFilterCategory_addsCategory() {
        sut.toggleFilterCategory(.groceries)
        #expect(sut.filterCategoryIds == ["groceries"])
    }

    @Test
    func toggleFilterCategory_removesOnSecondToggle() {
        sut.toggleFilterCategory(.groceries)
        sut.toggleFilterCategory(.groceries)
        #expect(sut.filterCategoryIds.isEmpty)
    }

    @Test
    func toggleFilterCategory_categoriesAreIndependent() {
        sut.toggleFilterCategory(.groceries)
        sut.toggleFilterCategory(.dining)
        sut.toggleFilterCategory(.groceries)
        #expect(sut.filterCategoryIds == ["dining"])
    }

    @Test
    func toggleFilterCategory_reloadsTransactionsWithFilter() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        await sut.loadData()
        await sut.toggleFilterCategory(.groceries).value
        await waitUntil { sut.transactionsState.data.count == 1 }
        #expect(sut.transactionsState.data.count == 1)
        #expect(sut.transactionsState.data.first?.categoryId == "groceries")
    }

    // MARK: - resetFilterCategories

    @Test
    func resetFilterCategories_clearsAllFilters() {
        sut.toggleFilterCategory(.groceries)
        sut.toggleFilterCategory(.dining)
        sut.resetFilterCategories()
        #expect(sut.filterCategoryIds.isEmpty)
    }

    @Test
    func resetFilterCategories_reloadsAllTransactions() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ]
        await sut.loadData()
        await sut.toggleFilterCategory(.groceries).value
        await sut.resetFilterCategories().value
        await waitUntil { sut.transactionsState.data.count == 2 }
        #expect(sut.transactionsState.data.count == 2)
    }

    // MARK: - live updates

    @Test
    func addTransactions_appearsWithoutReload() async throws {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        await sut.loadData()
        await waitUntil { sut.transactionsState.data.count == 1 }
        #expect(sut.transactionsState.data.count == 1)

        try await transactionsProvider.addTransactions([
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ])
        await waitUntil { sut.transactionsState.data.count == 2 }

        #expect(sut.transactionsState.data.count == 2)
    }

    @Test
    func addTransactions_doesNotDropLoadedContentIntoLoadingState() async throws {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        await sut.loadData()

        try await transactionsProvider.addTransactions([
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ])
        await waitUntil { sut.transactionsState.data.count == 2 }

        #expect(sut.viewLoadingState == .idle)
        #expect(sut.transactionsState.loadingState == .idle)
    }

    @Test
    func addTransactions_respectsActiveCategoryFilter() async throws {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        await sut.loadData()
        await sut.toggleFilterCategory(.groceries).value

        try await transactionsProvider.addTransactions([
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now),
        ])
        // The dining row must never reach a groceries-scoped stream, so poll on the stable
        // steady state (loaded + idle) rather than a count that would also hold before the write.
        await waitUntil { sut.transactionsState.loadingState == .idle && sut.transactionsState.data.count == 1 }

        #expect(sut.transactionsState.data.count == 1)
        #expect(sut.transactionsState.data.first?.categoryId == "groceries")
    }

    // MARK: - interim loading / error states (stream carries data forward)

    @Test
    func inFlightRefresh_keepsLoadedDataVisibleUntilSettledStateArrives() async throws {
        let existing = Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now)
        transactionsProvider.stubbedTransactions = [existing]
        await sut.loadData()
        await waitUntil { sut.transactionsState.data == [existing] }
        #expect(sut.transactionsState.data == [existing])

        // The provider signals a refetch is in flight, carrying its last-known data forward
        // as the stream contract requires, before a new settled result is available.
        transactionsProvider.emitLoading()
        await waitUntil { sut.transactionsState.loadingState == .loading }

        #expect(sut.transactionsState.loadingState == .loading)
        #expect(sut.transactionsState.data == [existing])
        // The full-screen spinner shouldn't come back once the initial load has finished.
        #expect(sut.viewLoadingState == .idle)

        let added = Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: .now)
        try await transactionsProvider.addTransactions([added])
        await waitUntil { sut.transactionsState.loadingState == .idle && sut.transactionsState.data.count == 2 }

        #expect(sut.transactionsState.loadingState == .idle)
        #expect(Set(sut.transactionsState.data.map(\.id)) == Set([existing.id, added.id]))
    }

    @Test
    func failedRefresh_keepsLoadedDataVisible() async throws {
        let existing = Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now)
        transactionsProvider.stubbedTransactions = [existing]
        await sut.loadData()
        await waitUntil { sut.transactionsState.data == [existing] }
        #expect(sut.transactionsState.data == [existing])

        transactionsProvider.emitError(NSError(domain: "test", code: 0))
        await waitUntil { sut.transactionsState.loadingState == .error }

        #expect(sut.transactionsState.loadingState == .error)
        #expect(sut.transactionsState.data == [existing])
        // A background failure after a successful load must not tear the list down.
        #expect(sut.viewLoadingState == .idle)
    }

    // MARK: - searchString

    @Test
    func searchString_reloadsTransactionsFilteredByVendor() async throws {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: "dining", date: .now),
        ]
        await sut.loadData()

        sut.searchString = "Whole"
        // Wait past the 300 ms search debounce for the reload to fire, then poll for propagation.
        try await Task.sleep(for: .milliseconds(350))
        await waitUntil { sut.transactionsState.data.count == 1 }

        #expect(sut.transactionsState.data.count == 1)
        #expect(sut.transactionsState.data.first?.vendor == "Whole Foods")
    }

    @Test
    func searchString_emptyString_returnsAllTransactions() async throws {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: "dining", date: .now),
        ]
        await sut.loadData()

        sut.searchString = "Whole"
        try await Task.sleep(for: .milliseconds(350))
        await waitUntil { sut.transactionsState.data.count == 1 }
        sut.searchString = ""
        try await Task.sleep(for: .milliseconds(350))
        await waitUntil { sut.transactionsState.data.count == 2 }

        #expect(sut.transactionsState.data.count == 2)
    }

    // MARK: - transactionCategoriesByDate

    @Test
    func transactionCategoriesByDate_groupsByCalendarDay() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: today),
            Transaction(id: "2", amount: 20, vendor: "B", categoryId: "dining", date: today),
            Transaction(id: "3", amount: 30, vendor: "C", categoryId: "rent", date: yesterday),
        ]
        await sut.loadData()
        await waitUntil { sut.transactionsState.data.count == 3 }

        #expect(sut.transactionCategoriesByDate[today]?.count == 2)
        #expect(sut.transactionCategoriesByDate[yesterday]?.count == 1)
    }
}
