import Foundation

/// Everything a single month page on the Home dashboard renders, computed for that page's month.
struct MonthSummary: Equatable {
    let month: MonthYear
    let headerText: String
    let totalSpending: Decimal
    let transactionCount: Int
    let percentageOfBudgetSpent: Double
    let lastMonthSpendingDiffPercent: Double?
    let categorySpending: [CategorySpending]
    let dailySpendingSums: [Decimal]
    /// True while transactions for this month (or the previous month, needed for the diff)
    /// haven't been loaded yet.
    let isLoading: Bool

    var maxCategorySpending: CategorySpending? {
        categorySpending.first
    }
}
