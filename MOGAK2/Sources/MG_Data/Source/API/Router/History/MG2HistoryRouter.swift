import Foundation
import Alamofire

enum MG2HistoryRouter {
    case createMogak(title: String, bigCategory: String, smallCategory: String?, color: String)
    case editMogak(mogakId: Int, title: String, bigCategory: String, smallCategory: String?, color: String)
    case createJogak(mogakId: Int, title: String, isRoutine: Bool, days: [String]?, today: String?, endDate: String?)
    case editJogak(jogakId: Int, title: String, isRoutine: Bool, days: [String]?, endDate: String?)
    case deleteMogak(mogakId: Int)
    case deleteJogak(jogakId: Int)
}

extension MG2HistoryRouter: RequestTarget {
    var path: String {
        switch self {
        case .createMogak, .editMogak:
            return "/api/modarats/mogaks"
        case .createJogak:
            return "/api/modarats/mogaks/jogaks"
        case .editJogak(let jogakId, _, _, _, _):
            return "/api/modarats/mogaks/jogaks/\(jogakId)"
        case .deleteMogak(let mogakId):
            return "/api/modarats/mogaks/\(mogakId)"
        case .deleteJogak(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createMogak, .createJogak:
            return .post
        case .editMogak, .editJogak:
            return .put
        case .deleteMogak, .deleteJogak:
            return .delete
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
        case .createMogak(let title, let bigCategory, let smallCategory, let color):
            var payload: [String: Any] = ["title": title, "bigCategory": bigCategory, "color": color]
            if let smallCategory { payload["smallCategory"] = smallCategory }
            return payload
        case .editMogak(let mogakId, let title, let bigCategory, let smallCategory, let color):
            var payload: [String: Any] = ["mogakId": mogakId, "title": title, "bigCategory": bigCategory, "color": color]
            if let smallCategory { payload["smallCategory"] = smallCategory }
            return payload
        case .createJogak(let mogakId, let title, let isRoutine, let days, let today, let endDate):
            var payload: [String: Any] = ["mogakId": mogakId, "title": title, "isRoutine": isRoutine]
            if let days { payload["days"] = days }
            if let today { payload["today"] = today }
            if let endDate { payload["endDate"] = endDate }
            return payload
        case .editJogak(_, let title, let isRoutine, let days, let endDate):
            var payload: [String: Any] = ["title": title, "isRoutine": isRoutine]
            if let days { payload["days"] = days }
            if let endDate { payload["endDate"] = endDate }
            return payload
        case .deleteMogak, .deleteJogak:
            return nil
        }
    }
}
