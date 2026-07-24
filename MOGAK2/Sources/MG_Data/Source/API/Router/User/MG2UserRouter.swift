import Foundation
import Alamofire

enum MG2UserRouter {
    case nicknameVerify(nickname: String)
    case nicknameChange(nickname: String)
    case jobChange(job: String)
    case getUserProfile
    case join(nickname: String, job: String, address: String)
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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUserProfile:
            return .get
        case .nicknameVerify, .join:
            return .post
        case .nicknameChange, .jobChange:
            return .put
        }
    }

    var requiresAuthorization: Bool {
        switch self {
        case .nicknameVerify:
            return false
        case .nicknameChange, .jobChange, .getUserProfile, .join:
            return true
        }
    }

    var headers: [String: String]? {
        switch self {
        case .nicknameVerify, .nicknameChange, .jobChange, .getUserProfile, .join:
            return ["Accept": "application/json", "Content-Type": "application/json"]
        }
    }

    var body: [String : Any]? {
        switch self {
        case .nicknameVerify(let nickname), .nicknameChange(let nickname):
            return ["nickname": nickname]
        case .jobChange(let job):
            return ["job": job]
        case .join(let nickname, let job, let address):
            return [
                "request": [
                    "nickname": nickname,
                    "job": job,
                    "address": address
                ]
            ]
        case .getUserProfile:
            return nil
        }
    }
}
