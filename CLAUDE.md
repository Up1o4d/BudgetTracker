# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Adding files

This project uses `PBXFileSystemSynchronizedRootGroup` — new files are picked up automatically. Do not edit `project.pbxproj` when adding source files.

## Build & test commands

This is an Xcode project — use `xcodebuild` from the repo root:

```bash
# Build
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run all tests
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single test (Swift Testing)
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing BudgetTrackerTests/BudgetTrackerTests/testName
```

## Architecture

MVVM app with two tabs (Home, Activity) plus an Add-transaction sheet opened from the tab bar. Insights and Import tabs are planned but not implemented. See `docs/ARCHITECTURE.md` for the full rationale. Key layers:

```
View (SwiftUI)  →  ViewModel  →  TransactionsProviderProtocol / CategoriesProviderProtocol / AppSettingsProtocol
                                        ↓                                  ↓
                               SwiftData providers + AppSettings    InMemory providers + InMemoryAppSettings
                               (production)                         (development, previews)
```

**Dependency injection** — `AppDependencies` bundles the providers and settings, with `.swiftData()` (production) and `.inMemory()` (development) factories. It is constructed in `BudgetTrackerApp` and passed to `RootView` via `RootViewModel`; `RootView` constructs ViewModels at route boundaries. ViewModels receive protocol-typed dependencies via `init`; no singletons, no `@Environment` DI.

**Storage** — SwiftData is the production storage. `BudgetTrackerApp` currently uses `.inMemory()` during development; the `.swiftData()` call is commented out alongside it.

**Navigation** — `AppRouter` owns the selected tab, a `NavigationPath` per tab, and the presented sheet (`AppSheet`). `RootView` binds each `NavigationStack` to its tab's path and presents sheets. ViewModels that trigger navigation receive the router via `init`. Add `navigationDestination` modifiers in `RootView` as new routes are added.

**Providers** — `TransactionsProviderProtocol` and `CategoriesProviderProtocol` are the seam between the app and storage. Providers are actors that stream `DataState<T>` via `AsyncStream`: call `transactionsStream()` to get `(stream, uuid)`, observe the stream, and pass the same `uuid` to `fetchTransactions(uuid:filter:)`. Writes re-emit to every live stream. Shared stream logic lives in `DataStreamRegistry`.

**Category** — a `struct` (id, name, symbolName, colorHex) managed via `CategoriesProviderProtocol`. Defaults are in `Category.all` and seeded on first launch by `RootViewModel.runAppSetup()`. `Transaction` references a category by `categoryId: String`; ViewModels join them at display time, falling back to `Category.unknown`.

**`DataState` / `LoadingState`** — `DataState` (`loadingState`, `data`, `error`) is what provider streams emit; `.loading` and `.error` emissions carry the last-known data. `LoadingState` (`loading`/`idle`/`error`) drives UI states; `LoadingState.merged(_:)` combines several.

## Theming

Tokens live in `Design/Theme/`, applied via extensions in `Design/Extensions/`.

- **Colors** — two layers: raw palette (`Color+Palette.swift`) → semantic constants (`Color+ThemeColors.swift`, e.g. `Color.bgCanvas`, `Color.textPrimary`). Always use semantic names in views. Light/dark variants are encoded at the semantic layer via `Color(light:dark:)`.
- **Category colors** — come from `Category.colorHex`, rendered with `Color(hex:)`. This is the only sanctioned hex in views.
- **Typography** — `AppTextStyle` bundles font (the bundled Oxanium typeface) + spacing into named tokens (`bodyMD`, `displayXL`, etc.). Apply with `.textStyle(_:)`.
- **Screen root** — call `.screenDefaults()` on every new screen (sets `bodyMD`, `textPrimary`, `accentLime` tint, `bgCanvas` background, and dismisses the keyboard on background taps).
- **Helpers** — `.cardBackground()` for content sections, `.shimmering()` with `.redacted(reason: .placeholder)` for loading. Reusable components live in `Design/Components/`.

See `docs/THEMING.md` for the full reference.

## Testing

- Unit tests use **Swift Testing** (`@Test`, `#expect`) — target ViewModels with `MockTransactionsProvider` / `MockCategoriesProvider` (`BudgetTrackerTests/Mocks/`) and `InMemoryAppSettings`.
- Provider contract tests (`BudgetTrackerTests/ServiceTests/`) run the same suite against both the SwiftData and in-memory providers.
- View tests use **swift-snapshot-testing** — snapshot Views in a known state, in light and dark mode.
- Use the `write-tests` skill for detailed conventions.
