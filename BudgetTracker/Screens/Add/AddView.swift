import SwiftUI

struct AddView: View {
    @State var viewModel: AddViewModel
    @State var datePickerIsPresented: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("screen.add.title")

                amountSection

                vendorSection

                categorySection

                dateSection

                Button("Save") {
                    viewModel.save()
                }
                .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
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
                            Button(action: { viewModel.vendor = vendor }) {
                                Chip(text: vendor)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(backgroundCard)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading) {
            Text("CATEGORY") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            VStack {
                if viewModel.categoriesState.loadingState == .loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    FlowLayout {
                        ForEach(viewModel.categoriesState.data, id: \.self) { category in
                            Button(action: { viewModel.selectedCategory = category }) {
                                Chip(
                                    text: category.name,
                                    systemImage: category.symbolName,
                                    iconColor: Color(hex: category.colorHex),
                                    isSelected: viewModel.selectedCategory == category
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(backgroundCard)
        }
    }

    private var dateSection: some View {
        VStack(alignment: .leading) {
            Text("DATE") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            VStack(spacing: 16.0) {
                Button(action: { datePickerIsPresented = true }) {
                    HStack {
                        Text(viewModel.date.formatted("dd/MM/yyyy"))
                        Spacer()
                        Image(systemName: "calendar")
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $datePickerIsPresented) {
                    DatePicker(
                        "Select Date",
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .onChange(of: viewModel.date) {
                        datePickerIsPresented = false
                    }
                }

                FlowLayout {
                    ForEach(viewModel.quickDateOptions, id: \.daysAgo) { option in
                        Button(action: { viewModel.selectQuickDateOption(option) }) {
                            Chip(
                                text: option.label,
                                isSelected: viewModel.quickDateOptionIsSelected(option)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
