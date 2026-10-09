import Foundation

struct MonthYear {
    let month: Int
    let year: Int

    static var current: MonthYear {
        MonthYear(
            month: Calendar.current.component(.month, from: .now),
            year: Calendar.current.component(.year, from: .now)
        )
    }

    var previousMonth: MonthYear {
        month == 1 ? MonthYear(month: 12, year: year - 1) : MonthYear(month: month - 1, year: year)
    }

    var nextMonth: MonthYear {
        month == 12 ? MonthYear(month: 1, year: year + 1) : MonthYear(month: month + 1, year: year)
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
}
