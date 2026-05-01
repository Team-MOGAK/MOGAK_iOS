import Foundation
import Alamofire

enum MG2FollowRouter {
    case follow(nickname: String)
    case unfollow(nickname: String)
    case followCounts(nickname: String)
    case mentors(nickname: String)
    case motos(nickname: String)
}

extension MG2FollowRouter: RequestTarget {
    var path: String {
        switch self {
        case .follow(let nickname), .unfollow(let nickname):
            return "/api/users/follows/\(nickname)"
        case .followCounts(let nickname):
            return "/api/users/follows/counts/\(nickname)"
        case .mentors(let nickname):
            return "/api/users/follows/\(nickname)/mentors"
        case .motos(let nickname):
            return "/api/users/follows/\(nickname)/motos"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .follow:
            return .post
        case .unfollow:
            return .delete
        case .followCounts, .mentors, .motos:
            return .get
        }
    }

    var headers: [String : String]? {
        var header = ["accept": "application/json", "Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: "accessToken"), !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}
