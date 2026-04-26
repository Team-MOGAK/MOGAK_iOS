//
//  ScheduleStartRouter.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation
import Alamofire

enum ScheduleStartRouter {
    case getModalartList
    case detailModalart(modalartId: Int)
    case getDetailMogakData(modalartId: Int)
}

extension ScheduleStartRouter: RequestTarget {
    
    var path: String {
        switch self {
        case .getModalartList:
            // MOGAK1 endpoint (active)
            return "/api/modarats"
            // MOGAK2 endpoint (inactive)
            // return "/v2/modarats"
        case .detailModalart(let modalartId):
            // MOGAK1 endpoint (active)
            return "/api/modarats/\(modalartId)"
            // MOGAK2 endpoint (inactive)
            // return "/v2/modarats/\(modalartId)"
        case .getDetailMogakData(let modalartId):
            // MOGAK1 endpoint (active)
            return "/api/modarats/\(modalartId)/mogaks"
            // MOGAK2 endpoint (inactive)
            // return "/v2/modarats/\(modalartId)/mogaks"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getModalartList, .detailModalart, .getDetailMogakData:
            return .get
        }
    }

    var headers: [String : String]? {
        return ["accept": "application/json"]
    }
}
