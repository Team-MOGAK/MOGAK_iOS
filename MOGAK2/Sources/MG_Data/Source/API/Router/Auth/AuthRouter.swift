import Foundation
import Alamofire

enum AuthRouter {
    case socialLogin(provider: String, token: String)
    case refresh(refreshToken: String)
    case logout
    case withdraw
}

extension AuthRouter: RequestTarget {
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
            return "/api/auth/\(provider)/login"
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
        switch self {
        case .refresh(let refreshToken):
            return [
                "accept": "application/json",
                "Content-Type": "application/json",
                "RefreshToken": refreshToken
            ]
        case .socialLogin, .logout, .withdraw:
            return [
                "accept": "application/json",
                "Content-Type": "application/json"
            ]
        }
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
