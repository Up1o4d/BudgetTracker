import SwiftUI

enum Tab: CaseIterable, Hashable {
    case home, activity, add

    var name: LocalizedStringKey {
        switch self {
        case .home: "screen.home.title"
        case .activity: "screen.activity.title"
        case .add: "screen.add.title"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .activity: "list.bullet"
        case .add: "plus.circle"
        }
    }
}
