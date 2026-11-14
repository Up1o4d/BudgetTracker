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
                HStack(spacing: 16) {
                    CategoryIconView(category: viewModel.category)
                    Text("Total") // TODO: Localize
                    Spacer()
                    Text(viewModel.totalAmount, format: .currency(code: viewModel.currency))
                        .textStyle(.bodyMDSemibold)
                }
                .listRowBackground(Color.bgSurface)
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
