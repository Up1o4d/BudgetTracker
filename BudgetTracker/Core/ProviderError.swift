import Foundation

/// Shared error domain for the provider layer. A single home so providers don't each redefine
/// their own error type; add cases here as new provider failure modes arise.
enum ProviderError: Error {
    case unknown
}
