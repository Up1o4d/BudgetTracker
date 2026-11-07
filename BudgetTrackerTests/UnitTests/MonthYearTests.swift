@testable import BudgetTracker
import Foundation
import Testing

struct MonthYearTests {
    // 2026-04-16 12:00:00 UTC — mid-April 2026 (30-day month).
    private let midMonth = Date(timeIntervalSince1970: 1_776_340_800)
    // 2026-04-30 12:00:00 UTC — last day of April 2026.
    private let lastDayOfMonth = Date(timeIntervalSince1970: 1_777_550_400)

    @Test
    func displayName_formatsAsMonthNameAndYear() {
        #expect(MonthYear.current(from: midMonth).displayName == "April 2026")
    }

    @Test
    func daysRemaining_returnsDaysLeftInMonth() {
        #expect(MonthYear.current(from: midMonth).daysRemaining(from: midMonth) == 14)
    }

    @Test
    func daysRemaining_isZeroOnLastDayOfMonth() {
        #expect(MonthYear.current(from: lastDayOfMonth).daysRemaining(from: lastDayOfMonth) == 0)
    }

    private func monthYear(year: Int, month: Int) -> MonthYear {
        MonthYear.current(from: Calendar.current.date(from: DateComponents(year: year, month: month, day: 15))!)
    }

    // MARK: - adding(months:)

    @Test
    func addingMonths_rollsForwardIntoNextYear() {
        #expect(monthYear(year: 2026, month: 12).adding(months: 1) == monthYear(year: 2027, month: 1))
    }

    @Test
    func addingMonths_rollsBackIntoPreviousYear() {
        #expect(monthYear(year: 2026, month: 1).adding(months: -1) == monthYear(year: 2025, month: 12))
    }

    @Test
    func addingMonths_handlesMultiYearOffsets() {
        #expect(monthYear(year: 2026, month: 4).adding(months: -28) == monthYear(year: 2023, month: 12))
        #expect(monthYear(year: 2026, month: 4).adding(months: 21) == monthYear(year: 2028, month: 1))
    }

    @Test
    func addingMonths_zeroReturnsSameMonth() {
        #expect(monthYear(year: 2026, month: 4).adding(months: 0) == monthYear(year: 2026, month: 4))
    }

    @Test
    func addingMonths_matchesRepeatedPreviousMonth() {
        let start = monthYear(year: 2026, month: 4)
        let stepped = (0 ..< 30).reduce(start) { month, _ in month.previousMonth }
        #expect(start.adding(months: -30) == stepped)
    }

    // MARK: - range(endingAt:count:)

    @Test
    func range_returnsConsecutiveMonthsOldestFirst() {
        let end = monthYear(year: 2026, month: 2)
        let expected = [
            monthYear(year: 2025, month: 11),
            monthYear(year: 2025, month: 12),
            monthYear(year: 2026, month: 1),
            monthYear(year: 2026, month: 2),
        ]
        #expect(MonthYear.range(endingAt: end, count: 4) == expected)
    }
}
