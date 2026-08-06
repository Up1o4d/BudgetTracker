import SwiftUI

struct AddView: View {
    @State var viewModel: AddViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("screen.add.title")

                amountSection

                vendorSection

                Button("Save") {
                    viewModel.save()
                }
                .disabled(!viewModel.isFormValid || viewModel.isSaving)
            }
            .padding(.horizontal, 16)
        }
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

    private var amountSection: some View {
        VStack(spacing: 16) {
            Text("AMOUNT") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            CurrencyTextField(
                amount: $viewModel.amount,
                currencyCode: viewModel.currencyCode
            )
            .multilineTextAlignment(.center)
            .textStyle(.displayXL)
        }
        .padding(16)
        .background(backgroundCard)
    }

    private var vendorSection: some View {
        VStack(alignment: .leading) {
            Text("VENDOR") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            VStack {
                TextField("Where did you spend?", text: $viewModel.vendor)
                if viewModel.transactionsState.loadingState == .loading {
                    ProgressView()
                } else {
                    FlowLayout {
                        ForEach(viewModel.sugestedVendors, id: \.self) { vendor in
                            Chip(text: vendor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(backgroundCard)
        }
    }

    private var backgroundCard: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.bgSurface)
            .stroke(Color.borderSubtle, lineWidth: 1)
    }
}

#Preview {
    AddView(viewModel: .init(
        transactionsProvider: InMemoryTransactionsProvider(),
        categoriesProvider: InMemoryCategoriesProvider(),
        appSettings: InMemoryAppSettings()
    ))
}
