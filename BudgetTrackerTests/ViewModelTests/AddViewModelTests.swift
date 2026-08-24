@testable import BudgetTracker
import Foundation
import Testing

struct AddViewModelTests {
    let transactionsProvider: MockTransactionsProvider
    let categoriesProvider: MockCategoriesProvider
    let appSettings: InMemoryAppSettings

    init() {
        transactionsProvider = MockTransactionsProvider()
        categoriesProvider = MockCategoriesProvider()
        appSettings = InMemoryAppSettings()
    }

    private func makeSUT(onSaved: (() -> Void)? = nil) -> AddViewModel {
        AddViewModel(
            transactionsProvider: transactionsProvider,
            categoriesProvider: categoriesProvider,
            appSettings: appSettings,
            onSaved: onSaved
        )
    }

    /// `save()` writes on a detached `Task`, so provider state lands one hop after the call
    /// returns. Polls until `condition` holds rather than sleeping a fixed interval.
    private func waitUntil(_ condition: () -> Bool, timeout: Duration = .seconds(2)) async {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while !condition(), ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    // MARK: - Initial state

    @Test
    func initialState() {
        let sut = makeSUT()
        #expect(sut.amount == nil)
        #expect(sut.vendor == "")
        #expect(sut.selectedCategory == nil)
        #expect(sut.isSaving == false)
        #expect(sut.isFormValid == false)
        #expect(sut.transactionsState.data.isEmpty)
        #expect(sut.categoriesState.data.isEmpty)
    }

    // MARK: - isFormValid

    @Test
    func isFormValid_falseWhenVendorAndAmountAreEmpty() {
        let sut = makeSUT()
        #expect(sut.isFormValid == false)
    }

    @Test
    func isFormValid_falseWhenAmountMissing() {
        let sut = makeSUT()
        sut.vendor = "Coffee Shop"
        #expect(sut.isFormValid == false)
    }

    @Test
    func isFormValid_falseWhenVendorIsBlank() {
        let sut = makeSUT()
        sut.vendor = "   "
        sut.amount = 5
        #expect(sut.isFormValid == false)
    }

    @Test
    func isFormValid_falseWhenCategoryMissing() {
        let sut = makeSUT()
        sut.vendor = "vendor"
        sut.amount = 5
        #expect(sut.isFormValid == false)
    }

    @Test
    func isFormValid_trueWhenVendorAmountAndCategoryPresent() {
        let sut = makeSUT()
        sut.vendor = "Coffee Shop"
        sut.amount = 5
        sut.selectedCategory = .dining
        #expect(sut.isFormValid == true)
    }

    // MARK: - currencyCode

    @Test
    func currencyCode_reflectsAppSettings() {
        appSettings.currency = "EUR"
        let sut = makeSUT()
        #expect(sut.currencyCode == "EUR")
    }

    // MARK: - suggestedVendors

    @Test
    func suggestedVendors_emptyWhenNoTransactionsLoaded() {
        let sut = makeSUT()
        #expect(sut.suggestedVendors.isEmpty)
    }

    @Test
    func suggestedVendors_dedupesPreservingFirstOccurrenceOrder() async {
        transactionsProvider.stubbedTransactions = [
            Transaction(id: "1", amount: 10, vendor: "Whole Foods", categoryId: "groceries", date: .now),
            Transaction(id: "2", amount: 20, vendor: "Sushi Bar", categoryId: "dining", date: .now),
            Transaction(id: "3", amount: 30, vendor: "Whole Foods", categoryId: "groceries", date: .now),
        ]
        let sut = makeSUT()
        await sut.loadTransactions()
        await waitUntil { sut.transactionsState.data.count == 3 }

        #expect(sut.suggestedVendors == ["Whole Foods", "Sushi Bar"])
    }

    @Test
    func suggestedVendors_limitedToSix() async {
        transactionsProvider.stubbedTransactions = (1 ... 8).map { index in
            Transaction(id: "\(index)", amount: 10, vendor: "Vendor \(index)", categoryId: "groceries", date: .now)
        }
        let sut = makeSUT()
        await sut.loadTransactions()
        await waitUntil { sut.transactionsState.data.count == 8 }

        #expect(sut.suggestedVendors.count == 6)
    }

    // MARK: - loadTransactions()

    @Test
    func loadTransactions_populatesTransactionsState() async {
        let transactions = [
            Transaction(id: "1", amount: 10, vendor: "A", categoryId: "groceries", date: .now),
        ]
        transactionsProvider.stubbedTransactions = transactions
        let sut = makeSUT()

        await sut.loadTransactions()
        await waitUntil { sut.transactionsState.data == transactions }

        #expect(sut.transactionsState.data == transactions)
    }

    @Test
    func loadTransactions_reusesExistingStreamOnSecondCall() async {
        let sut = makeSUT()
        await sut.loadTransactions()
        await sut.loadTransactions()

        #expect(transactionsProvider.transactionsStreamCallCount == 1)
        #expect(transactionsProvider.fetchTransactionsCallCount == 2)
    }

    // MARK: - loadCategories()

    @Test
    func loadCategories_populatesCategoriesState() async {
        let categories: [BudgetTracker.Category] = [.groceries, .dining]
        categoriesProvider.stubbedCategories = categories
        let sut = makeSUT()

        await sut.loadCategories()
        await waitUntil { sut.categoriesState.data == categories }

        #expect(sut.categoriesState.data == categories)
    }

    @Test
    func loadCategories_reusesExistingStreamOnSecondCall() async {
        let sut = makeSUT()
        await sut.loadCategories()
        await sut.loadCategories()

        #expect(categoriesProvider.categoriesStreamCallCount == 1)
        #expect(categoriesProvider.fetchCategoriesCallCount == 2)
    }

    // MARK: - save()

    @Test
    func save_doesNothingWhenFormIsInvalid() async {
        let sut = makeSUT()
        sut.vendor = "Coffee Shop"
        // amount and selectedCategory left unset.

        sut.save()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(transactionsProvider.stubbedTransactions.isEmpty)
        #expect(sut.isSaving == false)
    }

    @Test
    func save_doesNothingWhenCategoryMissing() async {
        let sut = makeSUT()
        sut.vendor = "Coffee Shop"
        sut.amount = 5
        // selectedCategory left unset.

        sut.save()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(transactionsProvider.stubbedTransactions.isEmpty)
    }

    @Test
    func save_addsTrimmedTransactionWhenFormIsValid() async throws {
        let sut = makeSUT()
        sut.vendor = "  Coffee Shop  "
        sut.amount = 5
        sut.selectedCategory = .dining
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        sut.date = fixedDate

        sut.save()
        await waitUntil { transactionsProvider.stubbedTransactions.count == 1 }

        let saved = try #require(transactionsProvider.stubbedTransactions.first)
        #expect(saved.vendor == "Coffee Shop")
        #expect(saved.amount == 5)
        #expect(saved.categoryId == "dining")
        #expect(saved.date == fixedDate)
    }

    @Test
    func save_callsOnSavedAfterAdding() async {
        var savedCallCount = 0
        let sut = makeSUT(onSaved: { savedCallCount += 1 })
        sut.vendor = "Coffee Shop"
        sut.amount = 5
        sut.selectedCategory = .dining

        sut.save()
        await waitUntil { savedCallCount == 1 }

        #expect(savedCallCount == 1)
    }

    @Test
    func save_resetsIsSavingAfterCompletion() async {
        let sut = makeSUT()
        sut.vendor = "Coffee Shop"
        sut.amount = 5
        sut.selectedCategory = .dining

        sut.save()
        await waitUntil { transactionsProvider.stubbedTransactions.count == 1 }

        #expect(sut.isSaving == false)
    }

    // MARK: - quickDateOptions

    @Test
    func quickDateOptions_returnsThreeOffsets() {
        let sut = makeSUT()
        #expect(sut.quickDateOptions.map(\.daysAgo) == [0, 1, 2])
    }
}
