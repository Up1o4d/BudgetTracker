//
//  BudgetTrackerApp.swift
//  BudgetTracker
//
//  Created by user on 30. 4. 26.
//

import SwiftUI

@main
struct BudgetTrackerApp: App {
    let appDependencies: AppDependencies = .init(
        transactionsProvider: InMemoryTransactionsProvider()
    )

    var body: some Scene {
        WindowGroup {
            RootView(appDependencies: appDependencies)
        }
    }
}
