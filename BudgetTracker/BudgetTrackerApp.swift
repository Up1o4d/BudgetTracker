//
//  BudgetTrackerApp.swift
//  BudgetTracker
//
//  Created by user on 30. 4. 26.
//

import SwiftData
import SwiftUI

@main
struct BudgetTrackerApp: App {
    let appDependencies: AppDependencies
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try .init(for: StoredTransaction.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        appDependencies = .init(
            transactionsProvider: SwiftDataTransactionsProvider(modelContainer: modelContainer)
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(appDependencies: appDependencies)
        }
    }
}
