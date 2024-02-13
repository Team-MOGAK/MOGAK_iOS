//
//  MogakDetailRouter.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/22.
//

import Foundation
import Alamofire

enum MogakDetailRouter: URLRequestConvertible {
    case getAllMogakDetailJogaks(_ mogakId: Int, _ date: String)
    case deleteMogak(_mogakId: Int)
    case deleteJogak(_ jogakId: Int)
    
    var endPoint: String {
        switch self {
        case .getAllMogakDetailJogaks(let mogakId, let date):
            return "api/modarats/mogaks/\(mogakId)/jogaks?date=\(date)"
        case .deleteMogak(let mogakId):
            return "api/modarats/mogaks/\(mogakId)"
        case .deleteJogak(let jogakId):
            return "api/modarats/mogaks/jogaks/\(jogakId)"
        }
    }
    
    //헤더
    var headers: HTTPHeaders {
        
        switch self {
//        default: return HTTPHeaders(["accept":"application/json", "Authorization" : accesstoken])
        default: return HTTPHeaders(["accept":"application/json"])
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllMogakDetailJogaks: return .get
        case .deleteMogak, .deleteJogak: return .delete
        }
    }
    
    var parameters: Parameters {
        return Parameters()
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = BASE_URL.appending(endPoint)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = URL(string: url)!
        
        var request = URLRequest(url: urlString)
        request.method = method
        request.headers = headers
        
        switch self {
        case .getAllMogakDetailJogaks:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .deleteMogak:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .deleteJogak:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }

        return request
    }
}
