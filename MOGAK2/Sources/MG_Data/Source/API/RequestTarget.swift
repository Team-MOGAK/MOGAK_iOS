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
    var baseURL: String { APIConfig.BaseURL }
    var headers: [String: String]? {
        ["accept": "application/json", "Content-Type": "application/json"]
    }
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
