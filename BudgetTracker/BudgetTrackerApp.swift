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

    init() {
        do {
            appDependencies = try .swiftData()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        // appDependencies = .inMemory()
    }

    var body: some Scene {
        WindowGroup {
            RootView(appDependencies: appDependencies)
        }
    }
}
