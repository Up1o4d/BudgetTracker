# Architecture

BudgetTracker is a small SwiftUI app for tracking personal transactions. The goal of this document is to describe how the app is structured and the reasoning behind the major decisions, so a reader can understand the codebase without reading every file.

## What the app does

- **Home** — a month-by-month spending dashboard. Months are paged horizontally; each page shows a summary against the monthly budget, a month-to-date spending chart, and spending broken down by category.
- **Activity** — the transaction list, grouped by date, with vendor search and category filtering.
- **Add** — a sheet (opened from the tab bar's add button) for entering a transaction: amount, vendor (with suggestions from past vendors), category, and date (with quick-date shortcuts).
- **Edit Budget** — a sheet (opened by tapping the budget column on Home's summary card) for setting the single app-wide monthly budget. The value is written to `AppSettings` only on Save; dismissing discards the draft.
- **Month Category Spending** — pushed onto the Home stack (via `AppRoute.monthCategorySpending`) by tapping a category row on Home. Shows that category's transactions for the tapped month, kept live by its own provider stream. Placeholder UI for now.

Not yet implemented: editing and deleting transactions, and the planned Insights and Import tabs.

## Layers

```
View (SwiftUI)
    │
    ▼
ViewModel
    │
    ▼
TransactionsProviderProtocol / CategoriesProviderProtocol / AppSettingsProtocol
    │
    ▼
SwiftData providers + AppSettings (UserDefaults)    (production)
InMemory providers  + InMemoryAppSettings           (development, previews, contract tests)
```

`AppDependencies` bundles the three dependencies and has two factories: `.swiftData()` (production) and `.inMemory()` (development). `BudgetTrackerApp` currently uses `.inMemory()` during development; the `.swiftData()` call is commented out next to it, ready to switch back.

`AppRouter` owns navigation state — the selected tab, one `NavigationPath` per tab, and the presented sheet (`AppSheet`). `RootView` binds each tab's `NavigationStack` to its path and presents sheets from `presentedSheet`.

## Key decisions

- **MVVM with constructor injection.** ViewModels receive their dependencies via `init`, all dependencies are protocol-typed. No singletons, no service locators, no environment-based dependency lookup.
- **Router-based navigation.** `AppRouter` owns the navigation paths and sheet state. Views observe the router; they do not own navigation themselves. This enables deep linking and makes navigation testable.
- **SwiftData behind a protocol.** `TransactionsProviderProtocol` and `CategoriesProviderProtocol` are the abstractions the rest of the app talks to. `SwiftDataTransactionsProvider` and `SwiftDataCategoriesProvider` are the production conformances. They map between the domain structs (`Transaction`, `Category`) and the `@Model` types (`StoredTransaction`, `StoredCategory`). ViewModels never know SwiftData exists. This keeps storage swappable and gives tests a clean seam.
- **Streaming providers.** Providers are actors that expose data as an `AsyncStream<DataState<T>>`. A ViewModel calls `transactionsStream()` to get a stream plus a `UUID` handle, observes the stream, and calls `fetchTransactions(uuid:filter:)` with that handle to set the stream's filter and trigger a fetch. Writes (`addTransactions`) re-emit to every live stream using each stream's stored filter, so all screens stay in sync without manual refreshes. `DataStreamRegistry` holds this shared logic (stream bookkeeping, superseding stale fetches, carrying last-known data forward on loading or error) so each provider doesn't reimplement it.
- **Stream cleanup.** Provider streams never finish on their own, and a ViewModel's observer task (`for await state in stream { self?.… = state }`) keeps iterating even after the ViewModel is gone — `[weak self]` only turns the assignment into a no-op. A leaked observer keeps its stream registered, so every write keeps re-fetching for a screen that no longer exists. Every ViewModel that owns observer tasks therefore cancels them, along with any other tasks it owns, in an `isolated deinit`; cancelling ends the iteration, which terminates the stream and lets the provider deregister it. `isolated deinit` (Swift 6.2+, iOS 18.4+ runtime) runs on the main actor, so it can touch the main-actor-isolated task properties directly — don't fall back to `nonisolated(unsafe)` properties. This matters most for screens that are dismissed or popped (sheets, pushed screens), but tab roots follow it too for consistency.
- **`DataState` and `LoadingState`.** Every stream emission is a `DataState` (`loadingState`, `data`, `error`). `.loading` and `.error` emissions carry the last-known data so lists never blank out. `LoadingState.merged(_:)` combines several states into one value for the view.
- **Composition at the route boundary.** `RootView` holds `AppDependencies` (via `RootViewModel`) and the `AppRouter`, and constructs the correct ViewModel for each tab and sheet. Child views receive a fully-constructed ViewModel via `init` and know nothing about the dependency container. If the route count grows, this can move into a dedicated factory.
- **App setup in `RootViewModel`.** On launch, `runAppSetup()` seeds the default categories into the categories provider and sets the currency from the user's locale (once each, tracked through `AppSettings`). The root view shows loading/error states around this.
- **Observable settings.** `AppSettings` and `InMemoryAppSettings` are `@Observable` (enforced by `AppSettingsProtocol: AnyObject, Observable`). ViewModels expose settings as plain computed passthroughs; SwiftUI's observation tracking follows the read through the ViewModel, so e.g. Home updates as soon as the Edit Budget sheet saves, without the ViewModel subscribing to anything.
- **`Category` as a struct with static instances.** Categories carry presentation metadata (name, SF Symbol, color hex) alongside identity, so a struct fits better than an enum. The defaults are exposed via `Category.all`, seeded into storage on first launch, and read back through `CategoriesProviderProtocol`. Transactions reference categories by `categoryId`; ViewModels join them at display time, falling back to `Category.unknown`.

## Testing strategy

- **Unit tests** use [Swift Testing](https://developer.apple.com/xcode/swift-testing/) and target ViewModels, with `MockTransactionsProvider` / `MockCategoriesProvider` (in `BudgetTrackerTests/Mocks/`) and `InMemoryAppSettings` as test doubles. Behavior is verified through the public interface of the ViewModel.
- **Provider contract tests** (`BudgetTrackerTests/ServiceTests/`) run the same suite against both the SwiftData and in-memory providers, so their observable behavior stays identical.
- **Snapshot tests** target Views, using [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing). Views receive a ViewModel or model in a known state and are snapshotted in light and dark mode, plus loading/redacted states where relevant.
- **The protocol seam is what makes all of this possible.** Without it, tests would need either a real SwiftData stack or a lot of mocking ceremony.

## Tech stack

- Swift, SwiftUI, Swift Concurrency
- SwiftData for persistence
- swift-snapshot-testing for view tests
- Swift Testing for unit tests
