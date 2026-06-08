import Foundation
import Alamofire

enum MG2UserRouter {
    case login(email: String)
    case join(payload: [String: any Sendable])
    case nicknameVerify(nickname: String)
    case nicknameChange(nickname: String)
    case jobChange(job: String)
    case imageChange
    case getUserProfile
}

extension MG2UserRouter: RequestTarget {
    var path: String {
        switch self {
        case .login:
            return "/api/users/login"
        case .join:
            return "/api/users/join"
        case .nicknameVerify:
            return "/api/users/nickname/verify"
        case .nicknameChange:
            return "/api/users/profile/nickname"
        case .jobChange:
            return "/api/users/profile/job"
        case .imageChange:
            return "/api/users/profile/image"
        case .getUserProfile:
            return "/api/users/profile"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUserProfile:
            return .get
        case .nicknameVerify, .login, .join:
            return .post
        case .nicknameChange, .jobChange, .imageChange:
            return .put
        }
    }

    var headers: [String : String]? {
        var header = ["accept": "application/json", "Content-Type": "application/json"]
        if let token = MG2TokenStore.accessToken, !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }

    var body: [String : Any]? {
        switch self {
        case .login(let email):
            return ["email": email]
        case .join(let payload):
            return payload.mapValues { $0 as Any }
        case .nicknameVerify(let nickname), .nicknameChange(let nickname):
            return ["nickname": nickname]
        case .jobChange(let job):
            return ["job": job]
        case .imageChange, .getUserProfile:
            return nil
        }
    }
}
