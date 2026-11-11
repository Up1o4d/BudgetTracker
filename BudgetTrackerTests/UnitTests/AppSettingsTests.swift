@testable import BudgetTracker
import Foundation
import Testing

struct AppSettingsTests {
    let suiteName: String
    let userDefaults: UserDefaults

    init() throws {
        suiteName = "AppSettingsTests.\(UUID().uuidString)"
        userDefaults = try #require(UserDefaults(suiteName: suiteName))
    }

    private func cleanUp() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    // MARK: - Initial state

    @Test
    func initialState_hasNoBudget() {
        defer { cleanUp() }
        let sut = AppSettings(userDefaults: userDefaults)

        #expect(sut.budget == nil)
        #expect(sut.didSeedCategories == false)
        #expect(sut.didSetCurrency == false)
    }

    // MARK: - Persistence

    @Test
    func budget_persistsAcrossInstances() {
        defer { cleanUp() }
        AppSettings(userDefaults: userDefaults).budget = Decimal(string: "1234.56")

        let sut = AppSettings(userDefaults: userDefaults)

        #expect(sut.budget == Decimal(string: "1234.56"))
    }

    @Test
    func budget_settingNilRemovesStoredValue() {
        defer { cleanUp() }
        let first = AppSettings(userDefaults: userDefaults)
        first.budget = 2300
        first.budget = nil

        let sut = AppSettings(userDefaults: userDefaults)

        #expect(sut.budget == nil)
        #expect(userDefaults.object(forKey: "budget") == nil)
    }

    @Test
    func flagsAndCurrency_persistAcrossInstances() {
        defer { cleanUp() }
        let first = AppSettings(userDefaults: userDefaults)
        first.currency = "JPY"
        first.didSetCurrency = true
        first.didSeedCategories = true

        let sut = AppSettings(userDefaults: userDefaults)

        #expect(sut.currency == "JPY")
        #expect(sut.didSetCurrency)
        #expect(sut.didSeedCategories)
    }
}
