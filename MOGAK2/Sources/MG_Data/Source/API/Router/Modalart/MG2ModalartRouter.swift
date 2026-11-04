import Foundation
import Alamofire

enum MG2ModalartRouter {
    case modalartList
    case modalartDetail(modalartId: Int)
    case modalartMogaks(modalartId: Int)
    case modalartProgress(modalartId: Int, date: String)
    case modalartCreate(title: String, color: String)
    case modalartEdit(id: Int, title: String, color: String)
    case modalartDelete(id: Int)
    case mogakOccurrences(mogakId: Int, date: String)
    case mogakJogaks(mogakId: Int)
    case mogakDelete(id: Int)
    case jogakDelete(id: Int)
}

extension MG2ModalartRouter: RequestTarget {
    var path: String {
        switch self {
        case .modalartList:
            return "/api/modarats"
        case .modalartDetail(let id):
            return "/api/modarats/\(id)"
        case .modalartMogaks(let id):
            return "/api/modarats/\(id)/mogaks"
        case .modalartProgress(let id, _):
            return "/api/modarats/\(id)/progress"
        case .modalartCreate:
            return "/api/modarats"
        case .modalartEdit(let id, _, _):
            return "/api/modarats/\(id)"
        case .modalartDelete(let id):
            return "/api/modarats/\(id)"
        case .mogakOccurrences(let mogakId, _), .mogakJogaks(let mogakId):
            return "/api/mogaks/\(mogakId)/jogaks"
        case .mogakDelete(let id):
            return "/api/mogaks/\(id)"
        case .jogakDelete(let id):
            return "/api/jogaks/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .modalartList, .modalartDetail, .modalartMogaks, .modalartProgress, .mogakOccurrences, .mogakJogaks:
            return .get
        case .modalartCreate:
            return .post
        case .modalartEdit:
            return .patch
        case .modalartDelete, .mogakDelete, .jogakDelete:
            return .delete
        }
    }

    var headers: [String: String]? {
        guard case .modalartEdit = self else { return Self.jsonHeaders }
        return Self.mergePatchHeaders
    }

    var body: [String: Any]? {
        switch self {
        case .modalartCreate(let title, let color):
            // 기본 모다라트 생성은 기존처럼 색을 # 없이 보낸다.
            return ["title": title, "color": color]
        case .modalartEdit(_, let title, let color):
            return ["title": title, "color": MG2APIColorCoding.encode(color)]
        case .modalartList, .modalartDetail, .modalartMogaks, .modalartProgress, .modalartDelete, .mogakOccurrences, .mogakJogaks, .mogakDelete, .jogakDelete:
            return nil
        }
    }

    var query: [String: Any]? {
        switch self {
        case .mogakOccurrences(_, let date), .modalartProgress(_, let date):
            return ["date": date]
        default:
            return nil
        }
    }
}
