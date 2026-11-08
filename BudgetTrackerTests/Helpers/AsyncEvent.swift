/// A latch that can be awaited before it is signalled and resumes any/all waiters once signalled —
/// used to deterministically order concurrent work without sleeps.
actor AsyncEvent {
    private var isSignalled = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func signal() {
        isSignalled = true
        for waiter in waiters { waiter.resume() }
        waiters.removeAll()
    }

    func wait() async {
        if isSignalled { return }
        await withCheckedContinuation { waiters.append($0) }
    }
}
