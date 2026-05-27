import Foundation
import Alamofire

enum MG2PostRouter {
    case posts(page: Int?, size: Int, sort: String?, address: String?)
    case postDetail(postId: Int)
    case postUpdate(postId: Int, contents: String)
    case postDelete(postId: Int)

    case comments(postId: Int)
    case commentCreate(postId: Int, contents: String)
    case commentUpdate(postId: Int, commentId: Int, contents: String)
    case commentDelete(postId: Int, commentId: Int)

    case like(postId: Int)

    case mogakPosts(mogakId: Int, page: Int?, size: Int)
    case jogakPostByDate(jogakId: Int, targetDate: String)
    case jogakPostCreate(jogakId: Int, payload: [String: Any])
}

extension MG2PostRouter: RequestTarget {
    var path: String {
        switch self {
        case .posts:
            return "/api/posts"
        case .postDetail(let postId), .postUpdate(let postId, _), .postDelete(let postId):
            return "/api/posts/\(postId)"
        case .comments(let postId), .commentCreate(let postId, _):
            return "/api/posts/\(postId)/comments"
        case .commentUpdate(let postId, let commentId, _), .commentDelete(let postId, let commentId):
            return "/api/posts/\(postId)/comments/\(commentId)"
        case .like:
            return "/api/posts/like"
        case .mogakPosts(let mogakId, _, _):
            return "/api/mogaks/\(mogakId)/posts"
        case .jogakPostByDate(let jogakId, _), .jogakPostCreate(let jogakId, _):
            return "/api/jogaks/\(jogakId)/posts"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .posts, .postDetail, .comments, .mogakPosts, .jogakPostByDate:
            return .get
        case .commentCreate, .like, .jogakPostCreate:
            return .post
        case .postUpdate, .commentUpdate:
            return .put
        case .postDelete, .commentDelete:
            return .delete
        }
    }

    var headers: [String : String]? {
        var header = ["accept": "application/json", "Content-Type": "application/json"]
        if let token = MG2TokenStore.accessToken, !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }

    var query: [String : Any]? {
        switch self {
        case .posts(let page, let size, let sort, let address):
            var q: [String: Any] = ["size": size]
            if let page { q["page"] = page }
            if let sort { q["sort"] = sort }
            if let address { q["address"] = address }
            return q
        case .mogakPosts(_, let page, let size):
            var q: [String: Any] = ["size": size]
            if let page { q["page"] = page }
            return q
        case .jogakPostByDate(_, let targetDate):
            return ["targetDate": targetDate]
        default:
            return nil
        }
    }

    var body: [String : Any]? {
        switch self {
        case .postUpdate(_, let contents):
            return ["contents": contents]
        case .commentCreate(_, let contents), .commentUpdate(_, _, let contents):
            return ["contents": contents]
        case .like(let postId):
            return ["postId": postId]
        case .jogakPostCreate(_, let payload):
            return payload
        default:
            return nil
        }
    }
}
