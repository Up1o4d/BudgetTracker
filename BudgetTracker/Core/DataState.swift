import Foundation

nonisolated struct DataState<T> {
    var loadingState: LoadingState = .loading
    var data: [T] = []
    var error: Error? = nil
}

extension DataState: Sendable where T: Sendable {}
