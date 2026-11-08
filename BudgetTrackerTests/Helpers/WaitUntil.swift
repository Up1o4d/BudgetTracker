import Testing

/// ViewModels apply stream emissions on a detached observer `Task`, so state pushed by a provider
/// lands one or more hops after the awaited call returns. Polls until `condition` holds rather than
/// sleeping a fixed interval.
///
/// The timeout is deliberately generous: tests, observer tasks and snapshot rendering all share the
/// main actor, so under contention (parallel suites, an attached debugger) the observer can be
/// scheduled seconds late. A passing test returns as soon as `condition` holds, so the timeout only
/// costs time on a genuine failure — which is recorded here rather than surfacing as a misleading
/// downstream `#expect` against stale state.
func waitUntil(
    _ condition: () -> Bool,
    timeout: Duration = .seconds(10),
    sourceLocation: SourceLocation = #_sourceLocation
) async {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while !condition() {
        guard ContinuousClock.now < deadline else {
            Issue.record("Timed out after \(timeout) waiting for condition", sourceLocation: sourceLocation)
            return
        }
        try? await Task.sleep(for: .milliseconds(5))
    }
}
