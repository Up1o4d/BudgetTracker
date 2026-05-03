import SwiftUI

struct ActivityView: View {
    @State var viewModel: ActivityViewModel

    var body: some View {
        VStack {
            Text("Activity")
        }
        .navigationTitle("Activity")
    }
}
