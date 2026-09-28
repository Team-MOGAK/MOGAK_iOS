import Foundation
import Alamofire

enum MG2AuthRouter {
    case socialLogin(provider: MG2SocialLoginProvider, token: String)
    case refresh(refreshToken: String)
    case logout
    case withdraw
}

extension MG2AuthRouter: RequestTarget {
    var requiresAuthorization: Bool {
        switch self {
        case .socialLogin, .refresh:
            return false
        case .logout, .withdraw:
            return true
        }
    }

    var path: String {
        switch self {
        case .socialLogin(let provider, _):
            return "/api/auth/\(provider.pathComponent)/login"
        case .refresh:
            return "/api/auth/refresh"
        case .logout:
            return "/api/auth/logout"
        case .withdraw:
            return "/api/auth/withdraw"
        }
    }

    var method: HTTPMethod {
        return .post
    }

    var headers: [String : String]? {
        guard case .refresh(let refreshToken) = self else { return Self.jsonHeaders }
        return Self.jsonHeaders.merging(["RefreshToken": refreshToken]) { $1 }
    }

    var body: [String : Any]? {
        switch self {
        case .socialLogin(_, let token):
            return ["token": token]
        case .refresh, .logout, .withdraw:
            return nil
        }
    }
}

private extension MG2SocialLoginProvider {
    var pathComponent: String {
        switch self {
        case .apple: "apple"
        case .google: "google"
        case .kakao: "kakao"
        }
    }
}
