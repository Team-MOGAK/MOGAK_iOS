import Foundation
import Alamofire

enum MG2ScheduleStartRouter {
    case jogakList(mogakId: Int, date: String)
    case jogakDailyCheck(date: String)
    case oneTimeJogaks(date: String)
    case addJogakToday(jogakId: Int)
    case dailyJogakDetail(jogakId: Int)
    case jogakFail(dailyJogakId: Int)
    case jogakSuccess(dailyJogakId: Int)
    case jogakMonth(startDay: String, endDay: String)
}

extension MG2ScheduleStartRouter: RequestTarget {

    var path: String {
        switch self {
        case .jogakList(let mogakId, let date):
            return "/api/modarats/mogaks/\(mogakId)/jogaks?date=\(date)"
        case .jogakDailyCheck(let date):
            return "/api/modarats/mogaks/jogaks?date=\(date)"
        case .oneTimeJogaks(let date):
            return "/api/modarats/mogaks/jogaks/daily?date=\(date)"
        case .addJogakToday(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)/start"
        case .dailyJogakDetail(let jogakId):
            return "/api/modarats/mogaks/jogaks/\(jogakId)/detail"
        case .jogakFail(let dailyJogakId):
            return "/api/modarats/mogaks/jogaks/\(dailyJogakId)/fail"
        case .jogakSuccess(let dailyJogakId):
            return "/api/modarats/mogaks/jogaks/\(dailyJogakId)/success"
        case .jogakMonth(let startDay, let endDay):
            return "/api/modarats/mogaks/jogaks/routines?startDay=\(startDay)&endDay=\(endDay)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .jogakList, .jogakDailyCheck, .oneTimeJogaks, .dailyJogakDetail, .jogakMonth:
            return .get
        case .addJogakToday:
            return .post
        case .jogakFail, .jogakSuccess:
            return .put
        }
    }

    var headers: [String : String]? {
        var header = ["accept": "application/json", "Content-Type": "application/json"]
        if let token = MG2TokenStore.accessToken, !token.isEmpty {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }
}
