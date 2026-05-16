import Foundation

struct DataState<T> {
    var loadingState: LoadingState = .loading
    var data: [T] = []
    var error: Error? = nil

    static var initial: DataState<T> { DataState() }

    var viewLoadingState: LoadingState {
        data.isEmpty ? loadingState : .idle
    }
}
