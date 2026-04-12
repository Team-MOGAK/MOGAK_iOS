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
}

extension ScheduleStartRouter: RequestTarget {
    
    var path: String {
        switch self {
        case .getModalartList:
            return "/modarats"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getModalartList:
            return .get
        }
    }
}
