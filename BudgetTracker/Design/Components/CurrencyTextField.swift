import SwiftUI

struct CurrencyTextField: View {
    @Binding private var amount: Decimal?
    @State private var digits: String
    @State private var pendingRestoreEpoch = 0

    private let currencyCode: String
    private let fractionDigits: Int

    private static let maxDigits = 12

    init(amount: Binding<Decimal?>, currencyCode: String) {
        _amount = amount
        self.currencyCode = currencyCode
        fractionDigits = Self.fractionDigits(for: currencyCode)
        _digits = State(initialValue: Self.digits(from: amount.wrappedValue, fractionDigits: fractionDigits))
    }

    private var decimalValue: Decimal {
        let raw = Decimal(string: digits) ?? 0
        guard fractionDigits > 0 else { return raw }
        return (raw as NSDecimalNumber).multiplying(byPowerOf10: Int16(-fractionDigits)).decimalValue
    }

    private var canonicalText: String {
        guard amount != nil else { return "" }
        return decimalValue.formatted(.currency(code: currencyCode))
    }

    private var textBinding: Binding<String> {
        Binding(get: { canonicalText }, set: { handleInput($0) })
    }

    var body: some View {
        TextField(
            "\((0 as Decimal).formatted(.currency(code: currencyCode)))",
            text: textBinding
        )
        .textFieldStyle(.plain)
        .keyboardType(.numberPad)
        .onChange(of: digits) {
            amount = digits.isEmpty ? nil : decimalValue
        }
        .onChange(of: amount) { _, newValue in
            let externalDigits = Self.digits(from: newValue, fractionDigits: fractionDigits)
            if externalDigits != digits {
                digits = externalDigits
            }
        }
    }

    /// Derives the new digit buffer from what the text field now displays, by comparing its
    /// length against `canonicalText` (the text before this edit) to detect an appended or
    /// removed character rather than diffing content — which stays correct even though
    /// grouping separators/currency symbols shift position as digits are typed.
    private func handleInput(_ newValue: String) {
        let delta = newValue.count - canonicalText.count
        guard delta != 0 else { return }

        let updatedDigits: String
        if delta > 0 {
            let appended = String(newValue.suffix(delta)).filter(\.isNumber)
            updatedDigits = String((digits + appended).suffix(Self.maxDigits))
        } else {
            updatedDigits = String(digits.dropLast(min(-delta, digits.count)))
        }

        commit(strippingExtraLeadingZeros(updatedDigits))
    }

    /// SwiftUI only re-pushes a `Binding<String>`'s value into a focused text field when it
    /// actually changes. If the normalized digits equal what's already there (e.g. typing a
    /// redundant leading zero), the raw un-formatted keystroke is left on screen until the
    /// field loses focus. Routing through an empty value first forces a real change, so
    /// SwiftUI corrects the display, then the real value is restored a moment later.
    ///
    /// `pendingRestoreEpoch` guards against a fast follow-up edit landing in that brief window:
    /// if another `commit` happens before the restore fires, the stale restore is dropped
    /// instead of clobbering the newer value.
    private func commit(_ newDigits: String) {
        pendingRestoreEpoch += 1
        guard digits == newDigits else {
            digits = newDigits
            return
        }

        let epoch = pendingRestoreEpoch
        digits = ""
        Task {
            try? await Task.sleep(for: .milliseconds(5))
            guard epoch == pendingRestoreEpoch else { return }
            digits = newDigits
        }
    }

    private func strippingExtraLeadingZeros(_ digits: String) -> String {
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

    private static func fractionDigits(for currencyCode: String) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.maximumFractionDigits
    }
}

#Preview {
    @Previewable @State var jpyAmount: Decimal?
    @Previewable @State var eurAmount: Decimal?

    VStack(spacing: 32) {
        CurrencyTextField(amount: $jpyAmount, currencyCode: "JPY")
        CurrencyTextField(amount: $jpyAmount, currencyCode: "JPY")
        Text("JPY: \(jpyAmount?.description ?? "nil")")

        CurrencyTextField(amount: $eurAmount, currencyCode: "EUR")
        Text("EUR: \(eurAmount?.description ?? "nil")")
    }
    .padding()
}
