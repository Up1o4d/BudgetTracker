@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct AddCategorySectionViewSnapshotTests {
    // MARK: - Loading

    @Test
    func addCategorySectionView_loading_light() {
        let view = AddCategorySectionView(categories: [], selectedCategory: .constant(nil), isLoading: true)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addCategorySectionView_loading_dark() {
        let view = AddCategorySectionView(categories: [], selectedCategory: .constant(nil), isLoading: true)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Populated, unselected

    @Test
    func addCategorySectionView_populatedUnselected_light() {
        let view = AddCategorySectionView(categories: Category.all, selectedCategory: .constant(nil), isLoading: false)
            .frame(width: 350, height: 260)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addCategorySectionView_populatedUnselected_dark() {
        let view = AddCategorySectionView(categories: Category.all, selectedCategory: .constant(nil), isLoading: false)
            .frame(width: 350, height: 260)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Populated, selected

    @Test
    func addCategorySectionView_populatedSelected_light() {
        let view = AddCategorySectionView(categories: Category.all, selectedCategory: .constant(.groceries), isLoading: false)
            .frame(width: 350, height: 260)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addCategorySectionView_populatedSelected_dark() {
        let view = AddCategorySectionView(categories: Category.all, selectedCategory: .constant(.groceries), isLoading: false)
            .frame(width: 350, height: 260)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
