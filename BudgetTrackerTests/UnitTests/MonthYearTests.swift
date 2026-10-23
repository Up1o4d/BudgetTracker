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
}
