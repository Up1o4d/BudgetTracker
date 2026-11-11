import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: AddViewModel

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "screen.add.title", onClose: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AddAmountSectionView(amount: $viewModel.amount, currencyCode: viewModel.currencyCode)

                    AddVendorSectionView(
                        vendor: $viewModel.vendor,
                        suggestedVendors: viewModel.suggestedVendors,
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
        .screenDefaults()
        .scrollContentBackground(.hidden)
        .task { await viewModel.loadTransactions() }
        .task { await viewModel.loadCategories() }
        .alert("screen.add.error.title", isPresented: $viewModel.showErrorAlert) {
        } message: {
            Text("screen.add.error.message")
        }
    }
}

#Preview {
    AddView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
