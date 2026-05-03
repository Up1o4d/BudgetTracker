final class InMemoryTransactionsProvider: TransactionsProviderProtocol {
    private var transactions: [Transaction] = [
        Transaction(id: "1", amount: 1200.00, vendor: "City Apartments", category: .rent),
        Transaction(id: "2", amount: 54.30, vendor: "Whole Foods", category: .groceries),
        Transaction(id: "3", amount: 12.50, vendor: "Uber", category: .transport),
        Transaction(id: "4", amount: 38.75, vendor: "The Italian Place", category: .dining),
        Transaction(id: "5", amount: 89.99, vendor: "Electric Company", category: .utilities),
        Transaction(id: "6", amount: 23.10, vendor: "Trader Joe's", category: .groceries),
        Transaction(id: "7", amount: 4.50, vendor: "City Bus Pass", category: .transport),
        Transaction(id: "8", amount: 62.00, vendor: "Sushi Bar", category: .dining),
        Transaction(id: "9", amount: 45.00, vendor: "Internet Provider", category: .utilities),
        Transaction(id: "10", amount: 15.99, vendor: "Amazon", category: .other),
    ]

    func fetchTransactions() async -> [Transaction] {
        transactions
    }
}
