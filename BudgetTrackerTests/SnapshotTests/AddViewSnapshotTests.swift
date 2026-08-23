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
            Transaction(id: "1", amount: 54.32, vendor: "Whole Foods", categoryId: Category.groceries.id, date: Date(timeIntervalSince1970: 1_699_000_000)),
            Transaction(id: "2", amount: 1_200, vendor: "Landlord LLC", categoryId: Category.rent.id, date: Date(timeIntervalSince1970: 1_698_900_000)),
            Transaction(id: "3", amount: 12.75, vendor: "Uber", categoryId: Category.transport.id, date: Date(timeIntervalSince1970: 1_698_800_000)),
            Transaction(id: "4", amount: 28.40, vendor: "Chipotle", categoryId: Category.dining.id, date: Date(timeIntervalSince1970: 1_698_700_000)),
            Transaction(id: "5", amount: 89.10, vendor: "Pacific Gas & Electric", categoryId: Category.utilities.id, date: Date(timeIntervalSince1970: 1_698_600_000)),
            Transaction(id: "6", amount: 15.99, vendor: "Netflix", categoryId: Category.other.id, date: Date(timeIntervalSince1970: 1_698_500_000)),
            Transaction(id: "7", amount: 42.18, vendor: "Trader Joe's", categoryId: Category.groceries.id, date: Date(timeIntervalSince1970: 1_698_400_000)),
            Transaction(id: "8", amount: 61.00, vendor: "Whole Foods", categoryId: Category.groceries.id, date: Date(timeIntervalSince1970: 1_698_300_000)),
            Transaction(id: "9", amount: 9.50, vendor: "Uber", categoryId: Category.transport.id, date: Date(timeIntervalSince1970: 1_698_200_000)),
            Transaction(id: "10", amount: 33.60, vendor: "Chipotle", categoryId: Category.dining.id, date: Date(timeIntervalSince1970: 1_698_100_000)),
        ]
    }
}
