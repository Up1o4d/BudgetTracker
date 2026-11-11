@testable import BudgetTracker
import Foundation
import Testing

struct EditBudgetViewModelTests {
    let appSettings: InMemoryAppSettings

    init() {
        appSettings = InMemoryAppSettings()
    }

    // MARK: - Initial state

    @Test
    func initialState_amountIsNilWhenBudgetNotSet() {
        let sut = EditBudgetViewModel(appSettings: appSettings)

        #expect(sut.amount == nil)
        #expect(sut.isValid == false)
    }

    @Test
    func initialState_amountIsSeededFromBudget() {
        appSettings.budget = 2300

        let sut = EditBudgetViewModel(appSettings: appSettings)

        #expect(sut.amount == 2300)
        #expect(sut.isValid)
    }

    @Test
    func currencyCode_readsFromAppSettings() {
        appSettings.currency = "EUR"

        let sut = EditBudgetViewModel(appSettings: appSettings)

        #expect(sut.currencyCode == "EUR")
    }

    // MARK: - isValid

    @Test
    func isValid_isFalseForZero() {
        let sut = EditBudgetViewModel(appSettings: appSettings)

        sut.amount = 0

        #expect(sut.isValid == false)
    }

    // MARK: - save()

    @Test
    func save_writesBudgetAndCallsOnSaved() {
        var onSavedCallCount = 0
        let sut = EditBudgetViewModel(appSettings: appSettings, onSaved: { onSavedCallCount += 1 })
        sut.amount = 1500

        sut.save()

        #expect(appSettings.budget == 1500)
        #expect(onSavedCallCount == 1)
    }

    @Test
    func save_doesNothingWhenInvalid() {
        appSettings.budget = 2300
        var onSavedCallCount = 0
        let sut = EditBudgetViewModel(appSettings: appSettings, onSaved: { onSavedCallCount += 1 })
        sut.amount = nil

        sut.save()

        #expect(appSettings.budget == 2300)
        #expect(onSavedCallCount == 0)
    }

    @Test
    func editingAmount_doesNotWriteBudgetUntilSaved() {
        appSettings.budget = 2300
        let sut = EditBudgetViewModel(appSettings: appSettings)

        sut.amount = 999

        #expect(appSettings.budget == 2300)
    }
}
