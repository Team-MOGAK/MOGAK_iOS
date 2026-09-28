import Alamofire
import Foundation

protocol RequestTarget: NetworkRequest, URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var query: [String: Any]? { get }
    var body: [String: Any]? { get }
}

extension RequestTarget {
    static var jsonHeaders: [String: String] {
        ["accept": "application/json", "Content-Type": "application/json"]
    }

    /// 수정 API는 바뀐 필드만 담은 merge patch만 받는다.
    static var mergePatchHeaders: [String: String] {
        ["accept": "application/json", "Content-Type": "application/merge-patch+json"]
    }

    var baseURL: String { APIConfig.baseURL }
    var headers: [String: String]? { Self.jsonHeaders }
    var query: [String: Any]? { nil }
    var body: [String: Any]? { nil }
    var requiresAuthorization: Bool { true }

    func makeURLRequest() throws -> URLRequest {
        try asURLRequest()
    }

    func asURLRequest() throws -> URLRequest {
        let url = try (baseURL + path).asURL()
        var request = try URLRequest(url: url, method: method)

        if let headers {
            request.headers = HTTPHeaders(headers)
        }

        if let query, !query.isEmpty {
            request = try URLEncoding.default.encode(request, with: query)
        }

        if let body, !body.isEmpty {
            request = try JSONEncoding.default.encode(request, with: body)
        }

        return request
    }
}
