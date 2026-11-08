---
description: Write Swift tests following project conventions. Use when asked to write, add, or implement tests for any layer of the app.
allowed-tools: Read, Bash, Write
argument-hint: "[file or class to test]"
---

## Test type selection

| Target | Test type | Location |
|---|---|---|
| ViewModel | Unit | `BudgetTrackerTests/ViewModelTests/` |
| Service / provider | Unit | `BudgetTrackerTests/ServiceTests/` |
| View / component | Snapshot — `swift-snapshot-testing` | `BudgetTrackerTests/SnapshotTests/` |
| Plain logic type (no dependencies) | Unit | `BudgetTrackerTests/UnitTests/` |

## Suite structure

- `struct`, not `class`
- Suite-level `sut` and dependencies as `let` properties, initialized in `init()`
- Mark `init() throws` if setup can fail (e.g. constructing a SwiftData `ModelContainer`)
- Swift Testing creates a fresh struct instance per test — no shared mutable state

## Naming

- `subject_condition` — e.g. `fetchTransactions_returnsEmptyWhenStoreIsEmpty`, `loadTransactions_setsErrorState`
- Simple initial-state checks may omit the subject — e.g. `initialState`
- `@Test` always goes on its own line above `func`, never on the same line

## Grouping with MARK comments

Use `// MARK: -` to group tests by method under test and by scenario within a method:

```swift
// MARK: - Initial state

// MARK: - loadTransactions() happy path

// MARK: - loadTransactions() error path

// MARK: - transactionsByDate
```

No other comments.

## Assertions

- `#expect(...)` for all assertions
- `try #require(...)` to unwrap optionals — fails the test immediately if nil
- Prefer value equality over separate count + field checks: `#expect(result == [transaction])`

## Async tests

Tests, ViewModel stream observers and snapshot rendering all share the main actor in one process (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`). Under load — parallel suites, an attached debugger — a task can be scheduled seconds late, so any wall-clock assumption flakes.

- Never use `Task.sleep` to wait for or order async work
- Wait for state with the shared `waitUntil { ... }` (`BudgetTrackerTests/Helpers/WaitUntil.swift`) — don't write a private copy or pass a short `timeout`; it records its own failure on timeout
- Order concurrent work with `AsyncEvent` (`Helpers/AsyncEvent.swift`), not sleeps
- In-memory providers: construct with `simulatedLatency: {}`; to hold a fetch in flight, pass `{ await gate.latency() }` with a `FirstCallLatencyGate` and `await gate.started.wait()` before starting the competing call
- Streams: wrap in `StreamRecorder` (`Helpers/StreamRecorder.swift`) — `nextSettled()` for expected values, `nextOrTimeout()` for "nothing else arrives" (best-effort: a late emission can slip past the window)
- Don't sleep after code that returns synchronously (e.g. a `guard` before a `Task`) — assert directly

```swift
await sut.loadTransactions()
await waitUntil { sut.transactionsState.data == transactions }
#expect(sut.transactionsState.data == transactions)
```

## Imports

```swift
import Testing
@testable import BudgetTracker
// Add only as needed:
import Foundation
import SwiftData
import SwiftUI
import SnapshotTesting
```

## Snapshot tests

```swift
@Suite(.snapshots(record: .missing))
struct MyViewSnapshotTests {
    @Test
    func component_light() { ... assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .light))) }
    @Test
    func component_dark() { ... assertSnapshot(of: view, as: .image(traits: .init(userInterfaceStyle: .dark))) }
}
```

## Before writing

1. Read the file(s) under test to understand the public surface
2. Check `BudgetTrackerTests/Mocks/` — a test double may already exist

## After writing

Run the new tests to confirm they pass:

```bash
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17' test \
  -only-testing BudgetTrackerTests/<SuiteName>
```
