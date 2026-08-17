import Foundation
import Alamofire

enum MG2UserRouter {
    case jobs
    case addresses
    case consents
    case nicknameVerify(nickname: String)
    case nicknameChange(nickname: String)
    case jobChange(job: String)
    case getUserProfile
    case join(nickname: String, job: String, address: String, consents: [MG2ConsentAgreement])
}

extension MG2UserRouter: RequestTarget {
    var path: String {
        switch self {
        case .jobs:
            return "/api/metadata/jobs"
        case .addresses:
            return "/api/metadata/addresses"
        case .consents:
            return "/api/consents"
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
        case .jobs, .addresses, .consents, .getUserProfile:
            return .get
        case .nicknameVerify, .join:
            return .post
        case .nicknameChange, .jobChange:
            return .put
        }
    }

    var requiresAuthorization: Bool {
        switch self {
        case .jobs, .addresses, .consents, .nicknameVerify:
            return false
        case .nicknameChange, .jobChange, .getUserProfile, .join:
            return true
        }
    }

    var headers: [String: String]? {
        switch self {
        case .jobs, .addresses, .consents, .nicknameVerify, .nicknameChange, .jobChange, .getUserProfile, .join:
            return ["Accept": "application/json", "Content-Type": "application/json"]
        }
    }

    var body: [String : Any]? {
        switch self {
        case .nicknameVerify(let nickname), .nicknameChange(let nickname):
            return ["nickname": nickname]
        case .jobChange(let job):
            return ["job": job]
        case .join(let nickname, let job, let address, let consents):
            return [
                "nickname": nickname,
                "job": job,
                "address": address,
                "consents": consents.map {
                    ["consentItemId": $0.consentItemId, "agreed": $0.agreed]
                }
            ]
        case .jobs, .addresses, .consents, .getUserProfile:
            return nil
        }
    }
}
