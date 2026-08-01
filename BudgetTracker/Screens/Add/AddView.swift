import SwiftUI

struct AddView: View {
    @State var viewModel: AddViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("screen.add.title")

                amountSection

                Button("Save") {
                    viewModel.save()
                }
                .disabled(!viewModel.isFormValid || viewModel.loadingState == .loading)
            }
            .padding(.horizontal, 16)
        }
        .overlay {
            if viewModel.loadingState == .loading {
                ProgressView()
            }
        }
        .defaultScreenStyle()
        .scrollContentBackground(.hidden)
    }

    private var amountSection: some View {
        VStack {
            Text("AMOUNT") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            TextField(
                "",
                text: $viewModel.amountText
            )
            .textStyle(.displayXL)
            .textFieldStyle(.plain)
            .keyboardType(.numberPad)
        }
        .padding(16)
        .background(backgroundCard)
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
        appSettings: InMemoryAppSettings()
    ))
}
