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
                                text: option.label,
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
}

#Preview {
    @Previewable @State var date = Date()

    let options: [QuickDateOption] = [
        QuickDateOption(label: "Today", daysAgo: 0),
        QuickDateOption(label: "Yesterday", daysAgo: 1),
        QuickDateOption(label: "2 days ago", daysAgo: 2),
    ]

    AddDateSectionView(date: $date, quickDateOptions: options)
        .padding()
}
