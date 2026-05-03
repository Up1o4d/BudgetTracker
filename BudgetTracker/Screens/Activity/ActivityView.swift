import SwiftUI

struct ActivityView: View {
    @State var viewModel: ActivityViewModel

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .initial, .loading:
                ProgressView()
            case .idle:
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
            case .empty:
                ContentUnavailableView("No Transactions", systemImage: "tray")
            case .error:
                ContentUnavailableView("Something went wrong", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Activity")
        .task {
            await viewModel.loadTransactions()
        }
    }
}
