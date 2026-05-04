# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Adding files

This project uses `PBXFileSystemSynchronizedRootGroup` — new files are picked up automatically. Do not edit `project.pbxproj` when adding source files.

## Build & test commands

This is an Xcode project — use `xcodebuild` from the repo root:

```bash
# Build
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test (Swift Testing)
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing BudgetTrackerTests/BudgetTrackerTests/testName
```

## Architecture

MVVM app with four tabs (Home, Insights, Activity, Import). See `ARCHITECTURE.md` for the full rationale. Key layers:

```
View (SwiftUI)  →  ViewModel  →  TransactionsProviderProtocol
                                        ↓                    ↓
                               SwiftDataTransactionsProvider  InMemoryTransactionsProvider
```

**Dependency injection** — `AppDependencies` is constructed in `BudgetTrackerApp` and passed to `RootView`, which constructs ViewModels at route boundaries. ViewModels receive protocol-typed dependencies via `init`; no singletons, no `@Environment` DI.

**Navigation** — `AppRouter` owns a `NavigationPath` per tab. `RootView` binds each `NavigationStack` to its tab's path. ViewModels that trigger navigation receive the router via `init`. Add `navigationDestination` modifiers in `RootView` as new routes are added.

**Provider protocol** — `TransactionsProviderProtocol` is the seam between the app and storage. `InMemoryTransactionsProvider` is the test/preview double; `SwiftDataTransactionsProvider` will be the production conformance once wired in (currently `BudgetTrackerApp` still uses `InMemoryTransactionsProvider`).

**Category** — a `struct` with static instances exposed via `Category.all`. Transactions embed the full `Category` struct directly.

**`LoadingState`** — enum used in ViewModels to drive loading/error/idle UI states.

## Testing

- Unit tests use **Swift Testing** (`@Test`, `#expect`) — target ViewModels with `InMemoryTransactionsProvider`.
- View tests use **swift-snapshot-testing** — snapshot Views with a ViewModel in a known state.
