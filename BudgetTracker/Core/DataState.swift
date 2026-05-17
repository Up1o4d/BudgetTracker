import Foundation

struct DataState<T> {
    var loadingState: LoadingState = .loading
    var data: [T] = []
    var error: Error? = nil
}
