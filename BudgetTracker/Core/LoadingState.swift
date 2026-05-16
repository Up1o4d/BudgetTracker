enum LoadingState {
    case loading, idle, error

    static func merged(_ states: LoadingState...) -> LoadingState {
        if states.contains(.loading) { return .loading }
        if states.contains(.error) { return .error }
        return .idle
    }
}
