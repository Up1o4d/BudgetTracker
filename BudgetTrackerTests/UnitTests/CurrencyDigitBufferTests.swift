import Foundation
import Testing

@testable import BudgetTracker

struct CurrencyDigitBufferTests {
    // MARK: - init(amount:fractionDigits:)

    @Test
    func init_nilAmount_producesEmptyDigits() {
        let buffer = CurrencyDigitBuffer(amount: nil, fractionDigits: 2)
        #expect(buffer.digits == "")
    }

    @Test
    func init_zeroAmount_producesSingleZeroDigit() {
        let buffer = CurrencyDigitBuffer(amount: 0, fractionDigits: 2)
        #expect(buffer.digits == "0")
    }

    @Test
    func init_usdAmount_scalesByTwoFractionDigits() {
        let buffer = CurrencyDigitBuffer(amount: 1234.56, fractionDigits: 2)
        #expect(buffer.digits == "123456")
    }

    @Test
    func init_jpyAmount_zeroFractionDigitsLeavesAmountUnscaled() {
        let buffer = CurrencyDigitBuffer(amount: 500, fractionDigits: 0)
        #expect(buffer.digits == "500")
    }

    @Test
    func init_bhdAmount_scalesByThreeFractionDigits() {
        let buffer = CurrencyDigitBuffer(amount: 1.234, fractionDigits: 3)
        #expect(buffer.digits == "1234")
    }

    @Test
    func init_fractionalAmountRoundsHalfUpToNearestMinorUnit() {
        let buffer = CurrencyDigitBuffer(amount: 12.005, fractionDigits: 2)
        #expect(buffer.digits == "1201")
    }

    @Test
    func init_negativeAmount_dropsSignKeepingDigitsOnly() {
        let buffer = CurrencyDigitBuffer(amount: -12.34, fractionDigits: 2)
        #expect(buffer.digits == "1234")
    }

    // MARK: - decimalValue

    @Test
    func decimalValue_emptyDigits_isZero() {
        let buffer = CurrencyDigitBuffer(digits: "", fractionDigits: 2)
        #expect(buffer.decimalValue == 0)
    }

    @Test
    func decimalValue_usdDigits_scalesDownByTwo() throws {
        let buffer = CurrencyDigitBuffer(digits: "123456", fractionDigits: 2)
        #expect(buffer.decimalValue == (try #require(Decimal(string: "1234.56"))))
    }

    @Test
    func decimalValue_jpyDigits_zeroFractionDigitsUnscaled() {
        let buffer = CurrencyDigitBuffer(digits: "500", fractionDigits: 0)
        #expect(buffer.decimalValue == 500)
    }

    @Test
    func decimalValue_bhdDigits_scalesDownByThree() throws {
        let buffer = CurrencyDigitBuffer(digits: "1234", fractionDigits: 3)
        #expect(buffer.decimalValue == (try #require(Decimal(string: "1.234"))))
    }

    // MARK: - applyingEdit(newText:previousText:) no-op

    @Test
    func applyingEdit_equalLengthTexts_returnsNil() {
        let buffer = CurrencyDigitBuffer(digits: "12", fractionDigits: 2)
        let updated = buffer.applyingEdit(newText: "$0.12", previousText: "$0.11")
        #expect(updated == nil)
    }

    // MARK: - applyingEdit(newText:previousText:) append

    @Test
    func applyingEdit_appendedDigit_shiftsIntoLeastSignificantPlace() throws {
        let buffer = CurrencyDigitBuffer(digits: "12", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "ab3", previousText: "ab"))
        #expect(updated.digits == "123")
    }

    @Test
    func applyingEdit_appendedNonDigitCharacterFromFormatting_isIgnored() throws {
        let buffer = CurrencyDigitBuffer(digits: "12", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "ab,", previousText: "ab"))
        #expect(updated.digits == "12")
    }

    @Test
    func applyingEdit_appendPastMaxDigitsBudget_dropsOldestDigit() throws {
        let buffer = CurrencyDigitBuffer(digits: "123456789012", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "ab3", previousText: "ab"))
        #expect(updated.digits == "234567890123")
    }

    @Test
    func applyingEdit_preservesFractionDigitsAcrossEdit() throws {
        let buffer = CurrencyDigitBuffer(digits: "12", fractionDigits: 3)
        let updated = try #require(buffer.applyingEdit(newText: "ab3", previousText: "ab"))
        #expect(updated.fractionDigits == 3)
    }

    // MARK: - applyingEdit(newText:previousText:) delete

    @Test
    func applyingEdit_deletedCharacter_dropsLastDigit() throws {
        let buffer = CurrencyDigitBuffer(digits: "123", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "ab", previousText: "abc"))
        #expect(updated.digits == "12")
    }

    @Test
    func applyingEdit_deleteDeltaLongerThanDigits_dropsAllDigits() throws {
        let buffer = CurrencyDigitBuffer(digits: "12", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "", previousText: "abcdefg"))
        #expect(updated.digits == "")
    }

    @Test
    func applyingEdit_deletingLastDigit_producesEmptyDigits() throws {
        let buffer = CurrencyDigitBuffer(digits: "1", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "a", previousText: "ab"))
        #expect(updated.digits == "")
    }

    // MARK: - applyingEdit(newText:previousText:) leading-zero normalization

    @Test
    func applyingEdit_appendingZeroToEmptyBuffer_normalizesToSingleZero() throws {
        let buffer = CurrencyDigitBuffer(digits: "", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "0", previousText: ""))
        #expect(updated.digits == "0")
    }

    @Test
    func applyingEdit_appendingZeroToExistingZero_collapsesToSingleZero() throws {
        let buffer = CurrencyDigitBuffer(digits: "0", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "a0", previousText: "a"))
        #expect(updated.digits == "0")
    }

    @Test
    func applyingEdit_appendingNonZeroAfterLeadingZero_stripsLeadingZero() throws {
        let buffer = CurrencyDigitBuffer(digits: "0", fractionDigits: 2)
        let updated = try #require(buffer.applyingEdit(newText: "a5", previousText: "a"))
        #expect(updated.digits == "5")
    }

    // MARK: - fractionDigits(for:)

    @Test
    func fractionDigits_usd_returnsTwo() {
        #expect(CurrencyDigitBuffer.fractionDigits(for: "USD") == 2)
    }

    @Test
    func fractionDigits_jpy_returnsZero() {
        #expect(CurrencyDigitBuffer.fractionDigits(for: "JPY") == 0)
    }

    @Test
    func fractionDigits_bhd_returnsThree() {
        #expect(CurrencyDigitBuffer.fractionDigits(for: "BHD") == 3)
    }

    @Test
    func fractionDigits_unknownCurrencyCode_fallsBackToTwo() {
        #expect(CurrencyDigitBuffer.fractionDigits(for: "NOTACODE") == 2)
    }
}
