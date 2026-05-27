import Foundation
import Alamofire

enum AuthRouter {
    case login(idToken: String)
    case socialLogin(provider: String, token: String)
    case refresh(refreshToken: String)
    case logout(accessToken: String?)
    case withdraw(accessToken: String?)
}

extension AuthRouter: RequestTarget {
    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
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
        case .logout(let accessToken), .withdraw(let accessToken):
            var header = [
                "accept": "application/json",
                "Content-Type": "application/json"
            ]
            if let accessToken, !accessToken.isEmpty {
                header["Authorization"] = "Bearer \(accessToken)"
            }
            return header
        case .login, .socialLogin:
            return [
                "accept": "application/json",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: [String : Any]? {
        switch self {
        case .login(let idToken):
            return ["id_token": idToken]
        case .socialLogin(_, let token):
            return ["token": token]
        case .refresh, .logout, .withdraw:
            return nil
        }
    }
}
