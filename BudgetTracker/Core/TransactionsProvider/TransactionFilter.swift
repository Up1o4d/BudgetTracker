import Foundation

nonisolated struct TransactionFilter {
    var categoryIds: Set<String>?
    var dateRange: ClosedRange<Date>?
    var vendorSubstring: String?
}

nonisolated extension TransactionFilter {
    func matches(_ transaction: Transaction) -> Bool {
        if let categoryIds, !categoryIds.contains(transaction.categoryId) {
            return false
        }
        if let dateRange, !dateRange.contains(transaction.date) {
            return false
        }
        if let vendorSubstring, !vendorSubstring.isEmpty,
           !transaction.vendor.localizedCaseInsensitiveContains(vendorSubstring) {
            return false
        }
        return true
    }
}
