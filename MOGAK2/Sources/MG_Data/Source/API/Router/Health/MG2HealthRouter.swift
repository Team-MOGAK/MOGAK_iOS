import Foundation
import Alamofire

enum MG2HealthRouter {
    /// 콜드스타트 중이면 503 {"status":"unavailable"}을 준다.
    case ready(timeout: TimeInterval)
}

extension MG2HealthRouter: RequestTarget {
    var requiresAuthorization: Bool { false }

    var path: String { "/health/ready" }

    var method: HTTPMethod { .get }

    func makeURLRequest() throws -> URLRequest {
        var request = try asURLRequest()
        if case .ready(let timeout) = self {
            request.timeoutInterval = timeout
        }
        return request
    }
}
