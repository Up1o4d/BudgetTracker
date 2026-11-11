import SwiftUI

struct EditBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: EditBudgetViewModel
    @FocusState private var isAmountFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            SheetHeader(title: "screen.editBudget.title", onClose: { dismiss() })

            VStack(spacing: 16) {
                Text("MONTHLY BUDGET") // TODO: Localize
                    .textStyle(.eyebrow)
                    .foregroundStyle(Color.textSecondary)
                CurrencyTextField(amount: $viewModel.amount, currencyCode: viewModel.currencyCode)
                    .multilineTextAlignment(.center)
                    .textStyle(.displayXL)
                    .focused($isAmountFocused)
            }
            .cardBackground()

            Button("Save") {
                viewModel.save()
            }
            .buttonStyle(PrimaryButtonStyle(isFullWidth: true))
            .disabled(!viewModel.isValid)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .presentationDragIndicator(.visible)
        .presentationDetents([.medium])
        .screenDefaults()
        .onAppear { isAmountFocused = true }
    }
}

#Preview("Empty") {
    EditBudgetView(viewModel: .init(appSettings: InMemoryAppSettings()))
}

#Preview("Filled") {
    EditBudgetView(viewModel: .init(appSettings: InMemoryAppSettings(budget: 2300)))
}
