import Foundation

/// `UserDefaults`-backed settings. Values are mirrored into stored properties (loaded in `init`,
/// written back in `didSet`) because `@Observable` only tracks stored properties.
@Observable
final class AppSettings: AppSettingsProtocol {
    @ObservationIgnored private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        didSeedCategories = userDefaults.bool(forKey: Keys.didSeedCategories)
        didSetCurrency = userDefaults.bool(forKey: Keys.didSetCurrency)
        currency = userDefaults.string(forKey: Keys.currency) ?? Locale.current.currency?.identifier ?? "USD"
        budget = userDefaults.string(forKey: Keys.budget).flatMap { Decimal(string: $0, locale: Self.posixLocale) }
    }

    var didSeedCategories: Bool {
        didSet { userDefaults.set(didSeedCategories, forKey: Keys.didSeedCategories) }
    }

    var didSetCurrency: Bool {
        didSet { userDefaults.set(didSetCurrency, forKey: Keys.didSetCurrency) }
    }

    var currency: String {
        didSet { userDefaults.set(currency, forKey: Keys.currency) }
    }

    /// Stored as a string — `Decimal` isn't a plist type, and `Double` would lose precision.
    var budget: Decimal? {
        didSet {
            if let budget {
                userDefaults.set(NSDecimalNumber(decimal: budget).description(withLocale: Self.posixLocale), forKey: Keys.budget)
            } else {
                userDefaults.removeObject(forKey: Keys.budget)
            }
        }
    }

    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    private enum Keys {
        static let didSeedCategories = "didSeedCategories"
        static let didSetCurrency = "didSetCurrency"
        static let currency = "currency"
        static let budget = "budget"
    }
}
