import Foundation

/// Implementations must be `@Observable` so views re-render when settings change.
protocol AppSettingsProtocol: AnyObject, Observable {
    var didSeedCategories: Bool { get set }
    var didSetCurrency: Bool { get set }
    var currency: String { get set }
    /// The single app-wide monthly budget. `nil` means the user hasn't set one yet.
    var budget: Decimal? { get set }
}
