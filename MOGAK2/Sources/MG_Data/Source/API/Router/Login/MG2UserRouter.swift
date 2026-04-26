import Foundation
import Alamofire

enum MG2UserRouter {
    case nicknameVerify(nickname: String)
    case nicknameChange(nickname: String)
    case jobChange(job: String)
    case getUserProfile
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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUserProfile:
            return .get
        case .nicknameVerify:
            return .post
        case .nicknameChange, .jobChange:
            return .put
        }
    }

    var headers: [String : String]? {
        var header = ["accept": "application/json", "Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: "accessToken"), !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }

    var body: [String : Any]? {
        switch self {
        case .nicknameVerify(let nickname), .nicknameChange(let nickname):
            return ["nickname": nickname]
        case .jobChange(let job):
            return ["job": job]
        case .getUserProfile:
            return nil
        }
    }
}
