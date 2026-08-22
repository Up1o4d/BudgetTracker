import Foundation

/// The raw digit state behind `CurrencyTextField`'s bank-style amount entry: each typed digit
/// becomes the new least-significant digit, shifting everything already entered one place to
/// the left. `digits` holds that buffer at the currency's minor-unit scale (e.g. "123456" at
/// `fractionDigits: 2` is $1,234.56); `decimalValue` converts it back to a real `Decimal`.
/// Pure value type, no SwiftUI dependency, so the digit-shifting/normalization logic can be
/// unit-tested directly rather than only through `CurrencyTextField`'s rendering.
struct CurrencyDigitBuffer: Equatable {
    let digits: String
    let fractionDigits: Int

    private static let maxDigits = 12

    init(digits: String, fractionDigits: Int) {
        self.digits = digits
        self.fractionDigits = fractionDigits
    }

    init(amount: Decimal?, fractionDigits: Int) {
        self.init(digits: Self.digits(from: amount, fractionDigits: fractionDigits), fractionDigits: fractionDigits)
    }

    var isEmpty: Bool { digits.isEmpty }

    var decimalValue: Decimal {
        let raw = Decimal(string: digits) ?? 0
        guard fractionDigits > 0 else { return raw }
        return (raw as NSDecimalNumber).multiplying(byPowerOf10: Int16(-fractionDigits)).decimalValue
    }

    /// Derives the updated buffer from what the text field now displays, by comparing its
    /// length against `previousText` (the text before this edit) to detect an appended or
    /// removed character rather than diffing content — which stays correct even though
    /// grouping separators/currency symbols shift position as digits are typed. Returns `nil`
    /// when the lengths match, meaning there's nothing to apply.
    func applyingEdit(newText: String, previousText: String) -> CurrencyDigitBuffer? {
        let delta = newText.count - previousText.count
        guard delta != 0 else { return nil }

        let updatedDigits: String
        if delta > 0 {
            let appended = String(newText.suffix(delta)).filter(\.isNumber)
            updatedDigits = String((digits + appended).suffix(Self.maxDigits))
        } else {
            updatedDigits = String(digits.dropLast(min(-delta, digits.count)))
        }

        return CurrencyDigitBuffer(digits: Self.strippingExtraLeadingZeros(updatedDigits), fractionDigits: fractionDigits)
    }

    /// `NumberFormatter.maximumFractionDigits`, once `currencyCode` is set, reports each
    /// currency's real minor-unit digit count (0 for JPY, 2 for USD/EUR, 3 for BHD/KWD) —
    /// there's no simpler Foundation API for this.
    static func fractionDigits(for currencyCode: String) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.maximumFractionDigits
    }

    /// Keeps `digits` in a single canonical form so two different keystrokes representing
    /// the same value (e.g. "0" then another "0") end up as the identical string —
    /// `CurrencyTextField.commit`'s equality check depends on that.
    private static func strippingExtraLeadingZeros(_ digits: String) -> String {
        guard let firstNonZero = digits.firstIndex(where: { $0 != "0" }) else {
            return digits.isEmpty ? "" : "0"
        }
        return String(digits[firstNonZero...])
    }

    private static func digits(from amount: Decimal?, fractionDigits: Int) -> String {
        func roundDecimal(_ val: Decimal) -> Decimal {
            var result = Decimal()
            var value = val
            NSDecimalRound(&result, &value, 0, .plain)
            return result
        }

        guard let amount else { return "" }
        let scaled = fractionDigits > 0
            ? (amount as NSDecimalNumber).multiplying(byPowerOf10: Int16(fractionDigits)).decimalValue
            : amount
        let rounded = roundDecimal(scaled)
        guard rounded != 0 else { return "0" }
        return "\(rounded)".filter(\.isNumber)
    }
}
