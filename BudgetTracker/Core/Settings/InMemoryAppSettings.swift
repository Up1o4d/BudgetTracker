import Foundation

@Observable
final class InMemoryAppSettings: AppSettingsProtocol {
    var didSeedCategories: Bool = false
    var didSetCurrency: Bool = false
    var currency: String = "USD"
    var budget: Decimal?

    init(budget: Decimal? = nil) {
        self.budget = budget
    }
}
