import SwiftUI

struct AddDateSectionView: View {
    @Binding var date: Date
    let quickDateOptions: [QuickDateOption]
    var referenceDate: Date = .now

    @State private var datePickerIsPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("DATE") // TODO: Localize
                .textStyle(.eyebrow)
                .foregroundStyle(Color.textSecondary)
            VStack(spacing: 16.0) {
                Button(action: { datePickerIsPresented = true }) {
                    HStack {
                        Text(date.formatted("dd/MM/yyyy"))
                        Spacer()
                        Image(systemName: "calendar")
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $datePickerIsPresented) {
                    DatePicker(
                        "Select Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .onChange(of: date) {
                        datePickerIsPresented = false
                    }
                }

                FlowLayout {
                    ForEach(quickDateOptions, id: \.daysAgo) { option in
                        Button(action: { date = option.toDate(from: referenceDate) }) {
                            Chip(
                                text: quickDateLabel(daysAgo: option.daysAgo),
                                isSelected: option.isSameDay(as: date, referenceDate: referenceDate)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .cardBackground()
        }
    }

    private func quickDateLabel(daysAgo: Int) -> String {
        switch daysAgo {
        case 0: String(localized: "screen.add.date.today")
        case 1: String(localized: "screen.add.date.yesterday")
        default: String(localized: "screen.add.date.daysAgo", defaultValue: "\(daysAgo) days ago")
        }
    }
}

#Preview {
    @Previewable @State var date = Date()

    let options: [QuickDateOption] = [
        QuickDateOption(daysAgo: 0),
        QuickDateOption(daysAgo: 1),
        QuickDateOption(daysAgo: 2),
    ]

    AddDateSectionView(date: $date, quickDateOptions: options)
        .padding()
}
