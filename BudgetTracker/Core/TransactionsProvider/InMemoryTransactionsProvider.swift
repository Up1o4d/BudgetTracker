import Foundation

final class InMemoryTransactionsProvider: TransactionsProviderProtocol {
    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private var transactions: [Transaction] = [
        Transaction(id: "1", amount: 1200.00, vendor: "City Apartments", category: .rent, date: date(2026, 1, 1)),
        Transaction(id: "2", amount: 54.30, vendor: "Whole Foods", category: .groceries, date: date(2026, 1, 3)),
        Transaction(id: "3", amount: 12.50, vendor: "Uber", category: .transport, date: date(2026, 1, 5)),
        Transaction(id: "4", amount: 38.75, vendor: "The Italian Place", category: .dining, date: date(2026, 1, 7)),
        Transaction(id: "5", amount: 89.99, vendor: "Electric Company", category: .utilities, date: date(2026, 1, 9)),
        Transaction(id: "6", amount: 23.10, vendor: "Trader Joe's", category: .groceries, date: date(2026, 1, 12)),
        Transaction(id: "7", amount: 4.50, vendor: "City Bus Pass", category: .transport, date: date(2026, 1, 14)),
        Transaction(id: "8", amount: 62.00, vendor: "Sushi Bar", category: .dining, date: date(2026, 1, 18)),
        Transaction(id: "9", amount: 45.00, vendor: "Internet Provider", category: .utilities, date: date(2026, 1, 22)),
        Transaction(id: "10", amount: 15.99, vendor: "Amazon", category: .other, date: date(2026, 1, 25)),
        Transaction(id: "11", amount: 1200.00, vendor: "City Apartments", category: .rent, date: date(2026, 2, 1)),
        Transaction(id: "12", amount: 67.40, vendor: "Whole Foods", category: .groceries, date: date(2026, 2, 2)),
        Transaction(id: "13", amount: 9.80, vendor: "Metro Card", category: .transport, date: date(2026, 2, 4)),
        Transaction(id: "14", amount: 44.00, vendor: "Burger Joint", category: .dining, date: date(2026, 2, 6)),
        Transaction(id: "15", amount: 92.50, vendor: "Gas & Power Co.", category: .utilities, date: date(2026, 2, 8)),
        Transaction(id: "16", amount: 31.20, vendor: "Costco", category: .groceries, date: date(2026, 2, 11)),
        Transaction(id: "17", amount: 18.00, vendor: "Lyft", category: .transport, date: date(2026, 2, 13)),
        Transaction(id: "18", amount: 75.50, vendor: "Thai Garden", category: .dining, date: date(2026, 2, 15)),
        Transaction(id: "19", amount: 39.99, vendor: "Spotify", category: .other, date: date(2026, 2, 17)),
        Transaction(id: "20", amount: 110.00, vendor: "Water Utility", category: .utilities, date: date(2026, 2, 20)),
        Transaction(id: "21", amount: 1200.00, vendor: "City Apartments", category: .rent, date: date(2026, 3, 1)),
        Transaction(id: "22", amount: 48.60, vendor: "Trader Joe's", category: .groceries, date: date(2026, 3, 3)),
        Transaction(id: "23", amount: 22.00, vendor: "Uber", category: .transport, date: date(2026, 3, 5)),
        Transaction(id: "24", amount: 55.00, vendor: "Pizza Palace", category: .dining, date: date(2026, 3, 7)),
        Transaction(id: "25", amount: 84.00, vendor: "Electric Company", category: .utilities, date: date(2026, 3, 10)),
        Transaction(id: "26", amount: 29.75, vendor: "Whole Foods", category: .groceries, date: date(2026, 3, 13)),
        Transaction(id: "27", amount: 6.00, vendor: "City Bus Pass", category: .transport, date: date(2026, 3, 15)),
        Transaction(id: "28", amount: 88.00, vendor: "Steakhouse", category: .dining, date: date(2026, 3, 18)),
        Transaction(id: "29", amount: 14.99, vendor: "Netflix", category: .other, date: date(2026, 3, 20)),
        Transaction(id: "30", amount: 47.00, vendor: "Internet Provider", category: .utilities, date: date(2026, 3, 23)),
        Transaction(id: "31", amount: 1200.00, vendor: "City Apartments", category: .rent, date: date(2026, 4, 1)),
        Transaction(id: "32", amount: 71.30, vendor: "Costco", category: .groceries, date: date(2026, 4, 3)),
        Transaction(id: "33", amount: 13.50, vendor: "Lyft", category: .transport, date: date(2026, 4, 5)),
        Transaction(id: "34", amount: 42.00, vendor: "Ramen House", category: .dining, date: date(2026, 4, 8)),
        Transaction(id: "35", amount: 95.00, vendor: "Gas & Power Co.", category: .utilities, date: date(2026, 4, 10)),
        Transaction(id: "36", amount: 36.90, vendor: "Trader Joe's", category: .groceries, date: date(2026, 4, 13)),
        Transaction(id: "37", amount: 8.00, vendor: "Metro Card", category: .transport, date: date(2026, 4, 15)),
        Transaction(id: "38", amount: 59.00, vendor: "Taco Spot", category: .dining, date: date(2026, 4, 17)),
        Transaction(id: "39", amount: 24.99, vendor: "Apple iCloud", category: .other, date: date(2026, 4, 19)),
        Transaction(id: "40", amount: 43.00, vendor: "Water Utility", category: .utilities, date: date(2026, 4, 21)),
        Transaction(id: "41", amount: 1200.00, vendor: "City Apartments", category: .rent, date: date(2026, 5, 1)),
        Transaction(id: "42", amount: 52.40, vendor: "Whole Foods", category: .groceries, date: date(2026, 5, 2)),
        Transaction(id: "43", amount: 11.00, vendor: "Uber", category: .transport, date: date(2026, 5, 2)),
        Transaction(id: "44", amount: 33.50, vendor: "The Italian Place", category: .dining, date: date(2026, 5, 3)),
        Transaction(id: "45", amount: 78.00, vendor: "Electric Company", category: .utilities, date: date(2026, 5, 3)),
        Transaction(id: "46", amount: 19.90, vendor: "Amazon", category: .other, date: date(2026, 5, 3)),
        Transaction(id: "47", amount: 27.60, vendor: "Trader Joe's", category: .groceries, date: date(2026, 5, 3)),
        Transaction(id: "48", amount: 5.50, vendor: "City Bus Pass", category: .transport, date: date(2026, 5, 3)),
        Transaction(id: "49", amount: 66.00, vendor: "Sushi Bar", category: .dining, date: date(2026, 5, 3)),
        Transaction(id: "50", amount: 49.99, vendor: "Internet Provider", category: .utilities, date: date(2026, 5, 3)),
    ]

    func fetchTransactions() async throws -> [Transaction] {
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
        return transactions
    }
}
