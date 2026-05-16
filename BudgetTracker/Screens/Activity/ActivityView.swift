import SwiftUI

struct ActivityView: View {
    @State var viewModel: ActivityViewModel

    var body: some View {
        Group {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
            case .idle:
                idleStateView
            case .error:
                ContentUnavailableView("screen.activity.error", systemImage: "exclamationmark.triangle")
            }
        }
        .defaultScreenStyle()
        .navigationTitle("screen.activity.title")
        .task {
            await viewModel.loadData()
        }
    }

    var idleStateView: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    Button(action: { viewModel.resetFilterCategories() }) {
                        // TODO: Localize string
                        Chip(text: "All", isSelected: viewModel.filterCategoryIds.isEmpty)
                    }
                    .buttonStyle(.plain)
                    ForEach(viewModel.categoriesState.data, id: \.self) { category in
                        Button(action: { viewModel.toggleFilterCategory(category) }) {
                            Chip(
                                text: category.name,
                                systemImage: category.symbolName,
                                iconColor: Color(hex: category.colorHex),
                                isSelected: viewModel.filterCategoryIds.contains(category.id)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }

            List {
                ForEach(viewModel.transactionsByDate.keys.sorted(by: >), id: \.self) { date in
                    Section(header: Text(date, style: .date)) {
                        ForEach(viewModel.transactionsByDate[date] ?? [], id: \.id) { transaction in
                            HStack {
                                Text(transaction.vendor)
                                Spacer()
                                Text(
                                    transaction.amount,
                                    format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                                )
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .overlay {
                if viewModel.transactionsState.loadingState == .loading {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    ActivityView(viewModel: .init(transactionsProvider: InMemoryTransactionsProvider(), categoriesProvider: InMemoryCategoriesProvider()))
}
