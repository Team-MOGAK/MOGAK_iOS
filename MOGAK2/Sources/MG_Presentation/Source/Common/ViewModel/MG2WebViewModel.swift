import Foundation

final class MG2WebViewModel {
    let url: URL?

    init(destination: MG2WebDestination) {
        url = URL(string: destination.rawValue)
    }
}
