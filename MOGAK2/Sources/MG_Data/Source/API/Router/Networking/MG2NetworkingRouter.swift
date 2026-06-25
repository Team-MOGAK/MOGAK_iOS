import Foundation
import Alamofire

enum MG2NetworkingRouter: URLRequestConvertible {
    case pacemakerFeeds(cursor: Int, size: Int)

    private var baseURL: String { APIConfig.BaseURL }

    private var method: HTTPMethod {
        switch self {
        case .pacemakerFeeds:
            return .get
        }
    }

    private var path: String {
        switch self {
        case .pacemakerFeeds:
            return "/api/posts/pacemakers"
        }
    }

    private var parameters: Parameters {
        switch self {
        case let .pacemakerFeeds(cursor, size):
            return ["cursor": cursor, "size": size]
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try (baseURL + path).asURL()
        var request = URLRequest(url: url)
        request.method = method

        if let accessToken = MG2TokenStore.accessToken, !accessToken.isEmpty {
            request.headers.add(.authorization(bearerToken: accessToken))
        }

        return try URLEncoding.default.encode(request, with: parameters)
    }
}
