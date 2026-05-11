import SwiftUI

struct AddView: View {
    @State var viewModel: AddViewModel

    var body: some View {
        Form {
            Section {
                HStack(alignment: .center) {
                    Text(Locale.current.currencySymbol ?? "$")
                        .textStyle(.titleMD)
                        .foregroundStyle(Color.textSecondary)
                    TextField("0.00", text: $viewModel.amountText)
                        .textStyle(.titleMD)
                        .keyboardType(.decimalPad)
                }
                TextField("Vendor", text: $viewModel.vendor)
                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
            }

            Section("Category") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Category.all) { category in
                            Button {
                                viewModel.selectedCategory = category
                            } label: {
                                Chip(systemImage: category.symbolName, text: category.name, iconColor: Color(hex: category.colorHex))
                                    .overlay {
                                        if viewModel.selectedCategory.id == category.id {
                                            Capsule().stroke(Color.accentLime, lineWidth: 2)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Button("Save") {
                viewModel.save()
            }
            .disabled(!viewModel.isFormValid || viewModel.loadingState == .loading)
        }
        .overlay {
            if viewModel.loadingState == .loading {
                ProgressView()
            }
        }
        .defaultScreenStyle()
        .scrollContentBackground(.hidden)
        .navigationTitle("screen.add.title")
    }
}

#Preview {
    AddView(viewModel: .init(transactionsProvider: InMemoryTransactionsProvider()))
}
