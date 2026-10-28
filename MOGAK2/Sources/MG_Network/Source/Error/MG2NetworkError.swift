import Foundation

/// 네트워크 실패. 화면에는 errorDescription만 보여주고, 서버가 준 원문은 DEBUG 로그로만 남긴다.
enum MG2NetworkError: LocalizedError {
    case offline
    case timeout
    /// retryAfter는 서버가 Retry-After로 알려준 최소 대기 시간(초).
    case rateLimited(retryAfter: TimeInterval?)
    case httpFailure(statusCode: Int)
    /// 요청을 만들지 못했거나 응답을 해석하지 못한 경우
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .offline:
            return "네트워크 연결을 확인해 주세요"
        case .timeout:
            return "응답이 늦어지고 있어요. 잠시 후 다시 시도해 주세요"
        case .rateLimited:
            return "요청이 많아요. 잠시 후 다시 시도해 주세요"
        case .httpFailure(400):
            return "입력한 내용을 다시 확인해 주세요"
        case .httpFailure(401):
            return "로그인이 만료됐어요. 다시 로그인해 주세요"
        case .httpFailure(403):
            return "접근 권한이 없어요"
        case .httpFailure(404):
            return "요청한 정보를 찾을 수 없어요"
        case .httpFailure(500...):
            return "서버에 문제가 생겼어요. 잠시 후 다시 시도해 주세요"
        case .httpFailure, .requestFailed:
            return "요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요"
        }
    }
}
