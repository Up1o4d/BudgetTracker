import SwiftUI

enum Tab: CaseIterable, Hashable {
    case home, activity

    var name: LocalizedStringKey {
        switch self {
        case .home: "screen.home.title"
        case .activity: "screen.activity.title"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .activity: "list.bullet"
        }
    }
}
