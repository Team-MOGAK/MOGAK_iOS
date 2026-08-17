import Foundation

enum MG2NetworkError: LocalizedError {
    case rateLimited(message: String)
    case storageUnavailable(message: String)
    case httpFailure(statusCode: Int, code: String?, message: String)

    var errorDescription: String? {
        switch self {
        case .rateLimited(let message),
             .storageUnavailable(let message),
             .httpFailure(_, _, let message):
            return message
        }
    }
}
