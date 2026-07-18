import Foundation
import Alamofire

enum MG2ScheduleStartRouter {
    case jogakDailyCheck(date: String)
    case addJogakToday(jogakId: Int)
    case dailyJogakDetail(jogakId: Int)
    case jogakFail(dailyJogakId: Int)
    case jogakSuccess(dailyJogakId: Int)
}

extension MG2ScheduleStartRouter: RequestTarget {

    var path: String {
        switch self {
        case .jogakDailyCheck:
            return "/api/modarats/mogaks/jogaks"
        case .addJogakToday(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)/start"
        case .dailyJogakDetail(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)/detail"
        case .jogakFail(let dailyJogakId):
            return "/api/modarats/mogaks/jogaks/\(dailyJogakId)/fail"
        case .jogakSuccess(let dailyJogakId):
            return "/api/modarats/mogaks/jogaks/\(dailyJogakId)/success"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .jogakDailyCheck, .dailyJogakDetail:
            return .get
        case .addJogakToday:
            return .post
        case .jogakFail, .jogakSuccess:
            return .put
        }
    }

    var query: [String: Any]? {
        switch self {
        case .jogakDailyCheck(let date):
            return ["date": date]
        case .addJogakToday, .dailyJogakDetail, .jogakFail, .jogakSuccess:
            return nil
        }
    }
}
