import SwiftUI

struct ActivityView: View {
    @State var viewModel: ActivityViewModel

    var body: some View {
        VStack {
            switch viewModel.viewLoadingState {
            case .loading:
                ProgressView()
            case .idle:
                categoriesPickerView
                transactionsListView
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

    var categoriesPickerView: some View {
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
    }

    var transactionsListView: some View {
        List {
            ForEach(viewModel.transactionsByDate.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(date, style: .date).textStyle(.eyebrow)) {
                    let transactions = viewModel.transactionsByDate[date] ?? []
                    ForEach(transactions) { transaction in
                        VStack(spacing: 0) {
                            HStack {
                                Text(transaction.vendor)
                                    .textStyle(.bodyMD)
                                Spacer()
                                Text(
                                    transaction.amount,
                                    format: .currency(code: viewModel.currency)
                                )
                            }
                        }
                    }
                    .listRowBackground(Color.bgSurface)
                    .listRowSeparatorTint(Color.borderSubtle)
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

#Preview {
    ActivityView(viewModel: .init(transactionsProvider: InMemoryTransactionsProvider(), categoriesProvider: InMemoryCategoriesProvider(), appSettings: InMemoryAppSettings()))
}
