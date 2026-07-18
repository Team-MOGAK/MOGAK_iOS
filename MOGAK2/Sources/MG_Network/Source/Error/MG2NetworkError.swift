import Foundation

enum MG2NetworkError: LocalizedError {
    case httpFailure(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .httpFailure(_, let message):
            return message
        }
    }
}
