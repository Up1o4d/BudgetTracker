@testable import BudgetTracker
import SnapshotTesting
import SwiftUI
import Testing

@Suite(.snapshots(record: .missing))
struct AddDateSectionViewSnapshotTests {
    // Fixed anchor passed as `referenceDate` so "today" means this exact instant, not the
    // real system clock — keeps both the header text and the quick-date highlight stable
    // regardless of which day the suite runs on.
    private static let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
    private static let quickDateOptions: [QuickDateOption] = [
        QuickDateOption(daysAgo: 0),
        QuickDateOption(daysAgo: 1),
        QuickDateOption(daysAgo: 2),
    ]

    // MARK: - Today selected

    @Test
    func addDateSectionView_todaySelected_light() {
        let view = AddDateSectionView(
            date: .constant(Self.referenceDate),
            quickDateOptions: Self.quickDateOptions,
            referenceDate: Self.referenceDate
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addDateSectionView_todaySelected_dark() {
        let view = AddDateSectionView(
            date: .constant(Self.referenceDate),
            quickDateOptions: Self.quickDateOptions,
            referenceDate: Self.referenceDate
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Yesterday selected

    @Test
    func addDateSectionView_yesterdaySelected_light() {
        let yesterday = QuickDateOption(daysAgo: 1).toDate(from: Self.referenceDate)
        let view = AddDateSectionView(
            date: .constant(yesterday),
            quickDateOptions: Self.quickDateOptions,
            referenceDate: Self.referenceDate
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addDateSectionView_yesterdaySelected_dark() {
        let yesterday = QuickDateOption(daysAgo: 1).toDate(from: Self.referenceDate)
        let view = AddDateSectionView(
            date: .constant(yesterday),
            quickDateOptions: Self.quickDateOptions,
            referenceDate: Self.referenceDate
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

    // MARK: - Custom date, no quick option selected

    @Test
    func addDateSectionView_customDateSelected_light() {
        let view = AddDateSectionView(
            date: .constant(Self.referenceDate),
            quickDateOptions: Self.quickDateOptions
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    @Test
    func addDateSectionView_customDateSelected_dark() {
        let view = AddDateSectionView(
            date: .constant(Self.referenceDate),
            quickDateOptions: Self.quickDateOptions
        )
        .frame(width: 350)
        assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
