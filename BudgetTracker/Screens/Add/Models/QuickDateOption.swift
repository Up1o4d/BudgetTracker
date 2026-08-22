import Foundation

struct QuickDateOption: Hashable {
    let daysAgo: Int

    func toDate(from now: Date = .now) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: now) ?? now
    }

    func isSameDay(as date: Date, referenceDate: Date = .now) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: toDate(from: referenceDate))
    }
}
