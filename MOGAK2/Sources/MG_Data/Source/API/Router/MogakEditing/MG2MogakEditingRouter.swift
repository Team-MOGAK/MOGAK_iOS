import Foundation
import Alamofire

enum MG2MogakEditingRouter {
    case createMogak(modaratId: Int, title: String, bigCategory: String, smallCategory: String?, color: String)
    case editMogak(mogakId: Int, title: String, bigCategory: String, smallCategory: String?, color: String)
    case createJogak(mogakId: Int, title: String, isRoutine: Bool, days: [String]?, today: String?, endDate: String?)
    case editJogak(jogakId: Int, title: String, isRoutine: Bool, days: [String]?, endDate: String?)
}

extension MG2MogakEditingRouter: RequestTarget {
    var path: String {
        switch self {
        case .createMogak:
            return "/api/mogaks"
        case .editMogak(let mogakId, _, _, _, _):
            return "/api/mogaks/\(mogakId)"
        case .createJogak:
            return "/api/jogaks"
        case .editJogak(let jogakId, _, _, _, _):
            return "/api/jogaks/\(jogakId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createMogak, .createJogak:
            return .post
        case .editMogak, .editJogak:
            return .put
        }
    }

    var body: [String : Any]? {
        switch self {
        case .createMogak(let modaratId, let title, let bigCategory, let smallCategory, let color):
            var payload: [String: Any] = ["modaratId": modaratId, "title": title, "bigCategory": bigCategory, "color": color]
            if let smallCategory { payload["smallCategory"] = smallCategory }
            return payload
        case .editMogak(_, let title, let bigCategory, let smallCategory, let color):
            var payload: [String: Any] = ["title": title, "bigCategory": bigCategory, "color": color]
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
        }
    }
}
