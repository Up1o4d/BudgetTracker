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
    func component_light() { ... assertSnapshot(..., traits: .init(userInterfaceStyle: .light)) }
    @Test
    func component_dark() { ... assertSnapshot(..., traits: .init(userInterfaceStyle: .dark)) }
}
```

## Before writing

1. Read the file(s) under test to understand the public surface
2. Check `BudgetTrackerTests/Mocks/` — a test double may already exist

## After writing

Run the new tests to confirm they pass:

```bash
xcodebuild -project BudgetTracker.xcodeproj -scheme BudgetTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16' test \
  -only-testing BudgetTrackerTests/<SuiteName>
```
