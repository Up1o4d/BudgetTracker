# Architecture

BudgetTracker is a small SwiftUI app for tracking personal transactions. The goal of this document is to describe how the app is structured and the reasoning behind the major decisions, so a reader can understand the codebase without reading every file.

## What the app does

- Show a list of transactions (date, amount, category, note)
- Add, edit, and delete transactions
- Filter transactions by category and/or date range

That's the V1 scope. Anything not in this list is intentionally out of scope.

## Layers

```
View (SwiftUI)
    │
    ▼
ViewModel
    │
    ▼
TransactionProviderProtocol
    │
    ▼
SwiftDataTransactionProvider   (production)
InMemoryTransactionProvider    (tests, previews)
```

A separate `Router` owns navigation state and is injected into ViewModels that need to trigger navigation. Navigation is driven by a `NavigationStack` bound to the router's path.

## Key decisions

- **MVVM with constructor injection.** ViewModels receive their dependencies via `init`, all dependencies are protocol-typed. No singletons, no service locators, no environment-based dependency lookup.
- **Router-based navigation.** A dedicated `Router` owns the navigation path. Views observe the router; they do not own navigation themselves. This enables deep linking and makes navigation testable.
- **SwiftData behind a protocol.** `TransactionProviderProtocol` is the abstraction the rest of the app talks to. `SwiftDataTransactionProvider` is the V1 conformance. The ViewModel never knows SwiftData exists. This keeps storage swappable and gives tests a clean seam.
- **Composition at the route boundary.** A `ViewFactory` (or the `RootView` directly, while the route count is small) holds `AppDependencies` and the `Router`, and constructs the correct ViewModel for each route. Child views receive a fully-constructed ViewModel via `init` and know nothing about the dependency container.
- **`Category` as a struct with static instances.** Categories carry presentation metadata (icon, color, display name) alongside identity, so a struct fits better than an enum. The set is fixed in V1 and exposed via `Category.all` for pickers. Transactions reference categories by id.

## Testing strategy

- **Unit tests** use [Swift Testing](https://developer.apple.com/xcode/swift-testing/) and target ViewModels, with `InMemoryTransactionProvider` as the test double. Behavior is verified through the public interface of the ViewModel.
- **Snapshot tests** target Views, using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing). Views receive a ViewModel in a known state and are snapshotted across the relevant device and dynamic-type configurations.
- **The protocol seam is what makes both possible.** Without it, tests would need either a real SwiftData stack or a lot of mocking ceremony.

## Tech stack

- Swift, SwiftUI, Swift Concurrency
- SwiftData for persistence
- swift-snapshot-testing for view tests
- Swift Testing for unit tests
