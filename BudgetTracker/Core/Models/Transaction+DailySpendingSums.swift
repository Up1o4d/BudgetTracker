import Foundation

extension Sequence where Element == Transaction {
    /// One spending sum per day of `month`, indexed from day 1.
    ///
    /// Past months cover every day; the current month covers days up to and including today;
    /// future months are empty. Transactions outside that range are ignored.
    func dailySpendingSums(in month: MonthYear, now: Date = .now) -> [Decimal] {
        let currentMonth = MonthYear.current(from: now)
        let dayCount: Int
        if month > currentMonth {
            dayCount = 0
        } else if month == currentMonth {
            dayCount = Calendar.current.component(.day, from: now)
        } else {
            dayCount = month.numberOfDaysInMonth
        }

        var sums = Array(repeating: Decimal.zero, count: dayCount)
        for transaction in self {
            let day = Calendar.current.component(.day, from: transaction.date)
            guard day <= dayCount else { continue }
            sums[day - 1] += transaction.amount
        }
        return sums
    }
}
