import SwiftUI

/// Placeholder UI — lists one category's transactions for one month.
struct MonthCategorySpendingView: View {
    @State var viewModel: MonthCategorySpendingViewModel

    var body: some View {
        Group {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
            case .idle:
                content
            case .error:
                // TODO: Localize
                ContentUnavailableView("Couldn't load transactions", systemImage: "exclamationmark.triangle")
            }
        }
        .screenDefaults()
        .navigationTitle(viewModel.title)
        .task { await viewModel.loadData() }
    }

    private var content: some View {
        List {
            Section {
                MonthCategorySpendingSummarySectionView(
                    category: viewModel.category,
                    month: viewModel.month,
                    totalAmount: viewModel.totalAmount,
                    transactionCount: viewModel.transactionCount,
                    dailySpendingSums: viewModel.dailySpendingSums,
                    currency: viewModel.currency
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                if viewModel.transactions.isEmpty {
                    Text("No transactions") // TODO: Localize
                        .foregroundStyle(Color.textSecondary)
                } else {
                    ForEach(viewModel.transactions, id: \.self) { transaction in
                        TransactionListCell(
                            transaction: transaction,
                            category: viewModel.category,
                            currency: viewModel.currency
                        )
                    }
                }
            }
            .listRowBackground(Color.bgSurface)
            .listRowSeparatorTint(Color.borderSubtle)
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack {
        MonthCategorySpendingView(viewModel: .init(
            month: .current().previousMonth,
            category: .groceries,
            transactionsProvider: InMemoryTransactionsProvider(),
            appSettings: InMemoryAppSettings()
        ))
    }
}
