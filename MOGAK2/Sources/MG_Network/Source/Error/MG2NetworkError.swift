import Foundation

enum MG2NetworkError: LocalizedError {
    /// retryAfter는 서버가 Retry-After로 알려준 최소 대기 시간(초).
    case rateLimited(message: String, retryAfter: TimeInterval?)
    case storageUnavailable(message: String)
    case httpFailure(statusCode: Int, code: String?, message: String)

    var errorDescription: String? {
        switch self {
        case .rateLimited(let message, _), .storageUnavailable(let message), .httpFailure(_, _, let message):
            return message
        }
    }
}
