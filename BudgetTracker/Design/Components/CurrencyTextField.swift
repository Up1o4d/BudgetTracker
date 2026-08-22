import SwiftUI

/// Bank-style amount entry: each digit typed becomes the new least-significant digit
/// (the currency's smallest unit), shifting everything already entered one place to the
/// left. `buffer` is the raw digit state driving that; `canonicalText` is what's actually
/// shown, derived fresh from it on every render.
struct CurrencyTextField: View {
    @Binding private var amount: Decimal?
    @State private var buffer: CurrencyDigitBuffer
    @State private var pendingRestoreEpoch = 0

    private let currencyCode: String
    private let fractionDigits: Int

    init(amount: Binding<Decimal?>, currencyCode: String) {
        _amount = amount
        self.currencyCode = currencyCode
        fractionDigits = CurrencyDigitBuffer.fractionDigits(for: currencyCode)
        _buffer = State(initialValue: CurrencyDigitBuffer(amount: amount.wrappedValue, fractionDigits: fractionDigits))
    }

    private var canonicalText: String {
        guard amount != nil else { return "" }
        return buffer.decimalValue.formatted(.currency(code: currencyCode))
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
        .onChange(of: buffer) {
            amount = buffer.isEmpty ? nil : buffer.decimalValue
        }
        .onChange(of: amount) { _, newValue in
            let external = CurrencyDigitBuffer(amount: newValue, fractionDigits: fractionDigits)
            if external != buffer {
                buffer = external
            }
        }
    }

    private func handleInput(_ newValue: String) {
        guard let updated = buffer.applyingEdit(newText: newValue, previousText: canonicalText) else { return }
        commit(updated)
    }

    /// SwiftUI only re-pushes a `Binding<String>`'s value into a focused text field when it
    /// actually changes. If the normalized buffer equals what's already there (e.g. typing a
    /// redundant leading zero), the raw un-formatted keystroke is left on screen until the
    /// field loses focus. Routing through an empty value first forces a real change, so
    /// SwiftUI corrects the display, then the real value is restored a moment later.
    ///
    /// `pendingRestoreEpoch` guards against a fast follow-up edit landing in that brief window:
    /// if another `commit` happens before the restore fires, the stale restore is dropped
    /// instead of clobbering the newer value.
    private func commit(_ newBuffer: CurrencyDigitBuffer) {
        pendingRestoreEpoch += 1
        guard buffer == newBuffer else {
            buffer = newBuffer
            return
        }

        let epoch = pendingRestoreEpoch
        buffer = CurrencyDigitBuffer(digits: "", fractionDigits: fractionDigits)
        Task {
            try? await Task.sleep(for: .milliseconds(5))
            guard epoch == pendingRestoreEpoch else { return }
            buffer = newBuffer
        }
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
