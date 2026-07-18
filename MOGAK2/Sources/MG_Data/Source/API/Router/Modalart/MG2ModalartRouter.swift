import Foundation
import Alamofire

enum MG2ModalartRouter {
    case modalartList
    case modalartDetail(modalartId: Int)
    case modalartMogaks(modalartId: Int)
    case modalartCreate(title: String, color: String)
    case modalartEdit(id: Int, title: String, color: String)
    case modalartDelete(id: Int)
    case mogakDetailJogaks(mogakId: Int, date: String)
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
        case .modalartCreate:
            return "/api/modarats"
        case .modalartEdit(let id, _, _):
            return "/api/modarats/\(id)"
        case .modalartDelete(let id):
            return "/api/modarats/\(id)"
        case .mogakDetailJogaks(let mogakId, _):
            return "/api/modarats/mogaks/\(mogakId)/jogaks"
        case .mogakDelete(let id):
            return "/api/modarats/mogaks/\(id)"
        case .jogakDelete(let id):
            return "/api/modarats/mogaks/jogaks/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .modalartList, .modalartDetail, .modalartMogaks, .mogakDetailJogaks:
            return .get
        case .modalartCreate:
            return .post
        case .modalartEdit:
            return .put
        case .modalartDelete, .mogakDelete, .jogakDelete:
            return .delete
        }
    }

    var body: [String: Any]? {
        switch self {
        case .modalartCreate(let title, let color), .modalartEdit(_, let title, let color):
            return ["title": title, "color": color]
        case .modalartList, .modalartDetail, .modalartMogaks, .modalartDelete, .mogakDetailJogaks, .mogakDelete, .jogakDelete:
            return nil
        }
    }

    var query: [String: Any]? {
        guard case .mogakDetailJogaks(_, let date) = self else { return nil }
        return ["date": date]
    }
}
