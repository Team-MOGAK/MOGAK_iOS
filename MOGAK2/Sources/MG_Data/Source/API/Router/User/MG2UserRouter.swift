import Foundation
import Alamofire

enum MG2UserRouter {
    case nicknameVerify(nickname: String)
    case nicknameChange(nickname: String)
    case jobChange(job: String)
    case getUserProfile
    case join
    case profileImageChange
}

extension MG2UserRouter: RequestTarget {
    var path: String {
        switch self {
        case .nicknameVerify:
            return "/api/users/nickname/verify"
        case .nicknameChange:
            return "/api/users/profile/nickname"
        case .jobChange:
            return "/api/users/profile/job"
        case .getUserProfile:
            return "/api/users/profile"
        case .join:
            return "/api/users/join"
        case .profileImageChange:
            return "/api/users/profile/image"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUserProfile:
            return .get
        case .nicknameVerify, .join:
            return .post
        case .nicknameChange, .jobChange, .profileImageChange:
            return .put
        }
    }

    var requiresAuthorization: Bool {
        switch self {
        case .nicknameVerify:
            return false
        case .nicknameChange, .jobChange, .getUserProfile, .join, .profileImageChange:
            return true
        }
    }

    var headers: [String: String]? {
        switch self {
        case .join, .profileImageChange:
            return ["Accept": "application/json"]
        case .nicknameVerify, .nicknameChange, .jobChange, .getUserProfile:
            return ["Accept": "application/json", "Content-Type": "application/json"]
        }
    }

    var body: [String : Any]? {
        switch self {
        case .nicknameVerify(let nickname), .nicknameChange(let nickname):
            return ["nickname": nickname]
        case .jobChange(let job):
            return ["job": job]
        case .getUserProfile, .join, .profileImageChange:
            return nil
        }
    }
}
