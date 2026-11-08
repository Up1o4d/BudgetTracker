/// Simulated provider latency that parks the first call until `release` is signalled and lets every
/// later call through immediately. Pass `{ await gate.latency() }` as a provider's
/// `simulatedLatency` to hold one fetch in flight while a newer one runs — the actor is reentrant
/// across the parked `await`, so the second call is never blocked behind the first.
actor FirstCallLatencyGate {
    let started = AsyncEvent()
    let release = AsyncEvent()
    private var callCount = 0

    func latency() async {
        callCount += 1
        guard callCount == 1 else { return }
        await started.signal()
        await release.wait()
    }
}
