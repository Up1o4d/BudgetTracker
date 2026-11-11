@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct EditBudgetViewSnapshotTests {
    // MARK: - Empty

    @Test
    func editBudgetView_empty_light() {
        let view = makeView(budget: nil)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func editBudgetView_empty_dark() {
        let view = makeView(budget: nil)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Filled

    @Test
    func editBudgetView_filled_light() {
        let view = makeView(budget: 2300)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func editBudgetView_filled_dark() {
        let view = makeView(budget: 2300)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    private func makeView(budget: Decimal?) -> some View {
        EditBudgetView(viewModel: .init(appSettings: InMemoryAppSettings(budget: budget)))
            .frame(width: 375, height: 400)
    }
}
