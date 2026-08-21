import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: AddViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AddAmountSectionView(amount: $viewModel.amount, currencyCode: viewModel.currencyCode)

                    AddVendorSectionView(
                        vendor: $viewModel.vendor,
                        suggestedVendors: viewModel.sugestedVendors,
                        isLoading: viewModel.transactionsState.loadingState == .loading
                    )

                    AddCategorySectionView(
                        categories: viewModel.categoriesState.data,
                        selectedCategory: $viewModel.selectedCategory,
                        isLoading: viewModel.categoriesState.loadingState == .loading
                    )

                    AddDateSectionView(date: $viewModel.date, quickDateOptions: viewModel.quickDateOptions)

                    Button("Save") {
                        viewModel.save()
                    }
                    .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
                    .disabled(!viewModel.isFormValid || viewModel.isSaving)
                }
            }
        }
        .padding(.horizontal, 16)
        .presentationDragIndicator(.visible)
        .overlay {
            if viewModel.isSaving {
                ProgressView()
            }
        }
        .defaultScreenStyle()
        .scrollContentBackground(.hidden)
        .task { await viewModel.loadTransactions() }
        .task { await viewModel.loadCategories() }
    }

    private var headerView: some View {
        HStack {
            Text("screen.add.title")
                .textStyle(.titleMD)

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.bgSurface)
                            .stroke(Color.borderSubtle, lineWidth: 1)
                    )
            }
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    AddView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
