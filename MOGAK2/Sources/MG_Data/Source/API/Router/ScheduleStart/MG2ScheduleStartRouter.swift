import Foundation
import Alamofire

enum MG2ScheduleStartRouter {
    case jogakOccurrences(date: String)
    case startJogak(jogakId: Int, scheduledDate: String)
    case jogakDetail(jogakId: Int)
    case failJogak(jogakId: Int, scheduledDate: String)
    case succeedJogak(jogakId: Int, scheduledDate: String)
}

extension MG2ScheduleStartRouter: RequestTarget {

    var path: String {
        switch self {
        case .jogakOccurrences:
            return "/api/jogaks"
        case .startJogak(let jogakId, let scheduledDate):
            return "/api/jogaks/\(jogakId)/executions/\(scheduledDate)/start"
        case .jogakDetail(let jogakId):
            return "/api/jogaks/\(jogakId)"
        case .failJogak(let jogakId, let scheduledDate):
            return "/api/jogaks/\(jogakId)/executions/\(scheduledDate)/fail"
        case .succeedJogak(let jogakId, let scheduledDate):
            return "/api/jogaks/\(jogakId)/executions/\(scheduledDate)/success"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .jogakOccurrences, .jogakDetail:
            return .get
        case .startJogak, .failJogak, .succeedJogak:
            return .post
        }
    }

    var query: [String: Any]? {
        switch self {
        case .jogakOccurrences(let date):
            return ["date": date]
        case .startJogak, .jogakDetail, .failJogak, .succeedJogak:
            return nil
        }
    }
}
