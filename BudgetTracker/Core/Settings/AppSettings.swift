import Foundation

final class AppSettings: AppSettingsProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var didSeedCategories: Bool {
        get { userDefaults.bool(forKey: "didSeedCategories") }
        set { userDefaults.set(newValue, forKey: "didSeedCategories") }
    }

    var didSetCurrency: Bool {
        get { userDefaults.bool(forKey: "didSetCurrency") }
        set { userDefaults.set(newValue, forKey: "didSetCurrency") }
    }

    var currency: String {
        get { userDefaults.string(forKey: "currency") ?? Locale.current.currency?.identifier ?? "USD" }
        set { userDefaults.set(newValue, forKey: "currency") }
    }
}
