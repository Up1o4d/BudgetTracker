@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct AddViewSnapshotTests {
    // MARK: - Empty

    /// `.task` loaders are attached but not awaited here, so the vendor/category sections
    /// render in their loading state — that's covered in detail by the section-level tests;
    /// this is purely a whole-screen layout/composition check.
    @Test
    func addView_empty_light() {
        let view = AddView(viewModel: makeViewModel())
            .frame(width: 375, height: 700)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addView_empty_dark() {
        let view = AddView(viewModel: makeViewModel())
            .frame(width: 375, height: 700)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Filled

    @Test
    func addView_filled_light() {
        let viewModel = makeViewModel()
        viewModel.amount = 42.50
        viewModel.vendor = "Test Vendor"
        viewModel.selectedCategory = .groceries
        viewModel.date = Date(timeIntervalSince1970: 1_700_000_000)

        let view = AddView(viewModel: viewModel)
            .frame(width: 375, height: 700)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addView_filled_dark() {
        let viewModel = makeViewModel()
        viewModel.amount = 42.50
        viewModel.vendor = "Test Vendor"
        viewModel.selectedCategory = .groceries
        viewModel.date = Date(timeIntervalSince1970: 1_700_000_000)

        let view = AddView(viewModel: viewModel)
            .frame(width: 375, height: 700)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    private func makeViewModel() -> AddViewModel {
        let viewModel = AddViewModel(
            transactionsProvider: InMemoryTransactionsProvider(),
            categoriesProvider: InMemoryCategoriesProvider(),
            appSettings: InMemoryAppSettings()
        )
        viewModel.transactionsState = DataState<BudgetTracker.Transaction>(
            loadingState: .idle,
            data: makeDummyTransactions()
        )
        viewModel.categoriesState = DataState<BudgetTracker.Category>(
            loadingState: .idle,
            data: BudgetTracker.Category.all
        )
        viewModel.date = Date(timeIntervalSince1970: 1_700_000_000)
        return viewModel
    }

    private func makeDummyTransactions() -> [BudgetTracker.Transaction] {
        return [
        ]
    }
}
