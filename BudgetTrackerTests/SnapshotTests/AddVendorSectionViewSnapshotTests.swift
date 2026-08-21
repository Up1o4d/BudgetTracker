@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct AddVendorSectionViewSnapshotTests {
    // MARK: - Loading

    @Test
    func addVendorSectionView_loading_light() {
        let view = AddVendorSectionView(vendor: .constant(""), suggestedVendors: [], isLoading: true)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addVendorSectionView_loading_dark() {
        let view = AddVendorSectionView(vendor: .constant(""), suggestedVendors: [], isLoading: true)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - No suggestions

    @Test
    func addVendorSectionView_noSuggestions_light() {
        let view = AddVendorSectionView(vendor: .constant(""), suggestedVendors: [], isLoading: false)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addVendorSectionView_noSuggestions_dark() {
        let view = AddVendorSectionView(vendor: .constant(""), suggestedVendors: [], isLoading: false)
            .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Suggestions, one selected

    @Test
    func addVendorSectionView_withSuggestionsOneSelected_light() {
        let view = AddVendorSectionView(
            vendor: .constant("Whole Foods"),
            suggestedVendors: ["Whole Foods", "Uber", "Netflix"],
            isLoading: false
        )
        .frame(width: 350, height: 160)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addVendorSectionView_withSuggestionsOneSelected_dark() {
        let view = AddVendorSectionView(
            vendor: .constant("Whole Foods"),
            suggestedVendors: ["Whole Foods", "Uber", "Netflix"],
            isLoading: false
        )
        .frame(width: 350, height: 160)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
