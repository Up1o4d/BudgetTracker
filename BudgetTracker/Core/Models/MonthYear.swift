import Foundation

struct MonthYear: Comparable, Hashable {
    let month: Int
    let year: Int

    private init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }

    static func < (lhs: MonthYear, rhs: MonthYear) -> Bool {
        (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }

    static func current(from now: Date = .now) -> MonthYear {
        MonthYear(
            month: Calendar.current.component(.month, from: now),
            year: Calendar.current.component(.year, from: now)
        )
    }

    var previousMonth: MonthYear {
        month == 1 ? MonthYear(month: 12, year: year - 1) : MonthYear(month: month - 1, year: year)
    }

    var nextMonth: MonthYear {
        month == 12 ? MonthYear(month: 1, year: year + 1) : MonthYear(month: month + 1, year: year)
    }

    func adding(months: Int) -> MonthYear {
        let totalMonths = year * 12 + (month - 1) + months
        let (newYear, monthIndex) = totalMonths.quotientAndRemainder(dividingBy: 12)
        // quotientAndRemainder truncates toward zero, so normalise a negative remainder.
        return monthIndex < 0
            ? MonthYear(month: monthIndex + 13, year: newYear - 1)
            : MonthYear(month: monthIndex + 1, year: newYear)
    }

    /// `count` consecutive months, oldest first, with `end` as the last element.
    static func range(endingAt end: MonthYear, count: Int) -> [MonthYear] {
        (0 ..< count).map { end.adding(months: $0 - count + 1) }
    }

    var monthDateRange: ClosedRange<Date> {
        let startOfMonth = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? .now
        let interval = Calendar.current.dateInterval(of: .month, for: startOfMonth) ?? DateInterval(start: startOfMonth, end: startOfMonth)
        return interval.start ... interval.end
    }

    var monthName: String {
        let date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? .now
        return date.formatted("MMMM")
    }

    var numberOfDaysInMonth: Int {
        let date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? .now
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }

    var displayName: String {
        let date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? .now
        return date.formatted("MMMM yyyy")
    }

    func daysRemaining(from now: Date = .now) -> Int {
        numberOfDaysInMonth - Calendar.current.component(.day, from: now)
    }
}
