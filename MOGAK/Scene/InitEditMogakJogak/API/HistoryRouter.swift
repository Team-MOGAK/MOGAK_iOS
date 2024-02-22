//
//  HistoryRouter.swift
//  MOGAK
//
//  Created by 이재혁 on 12/6/23.
//

import Foundation
import Alamofire

enum MogakRouter: URLRequestConvertible {
    
    case createMogak(data: MogakMainData)
    case deleteMogak(mogakId: Int)
    case editMogak(data: EditMogakRequestMainData)
    case createJogak(data: CreateJogakRequestMainData)
    case editJogak(data: EditJogakRequestMainData, jogakId: Int)
    case deleteJogak(jogakId: Int)
    
    var endPoint: String {
        switch self {
        case .createMogak, .editMogak: return "api/modarats/mogaks"
        case .deleteMogak(let mogakId): return "api/modarats/mogaks/\(mogakId)"
        case .createJogak: return "api/modarats/mogaks/jogaks"
        case .editJogak(_, let jogakId): return "api/modarats/mogaks/jogaks/\(jogakId)"
        case .deleteJogak(let jogakId): return "api/modarats/mogaks/jogaks/\(jogakId)"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        //default: return HTTPHeaders(["accept": "application/json", "Authorization": accesstoken])
        default: return HTTPHeaders(["accept": "application/json"])
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createMogak, .createJogak: return .post
        case .deleteMogak, .deleteJogak: return .delete
        case .editMogak, .editJogak: return .put
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
        case .createMogak(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        case .deleteMogak(let mogakId):
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .editMogak(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        case .createJogak(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        case .editJogak(let data,_):
            request = try JSONParameterEncoder().encode(data, into: request)
        case .deleteJogak(let jogakId):
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        
        return request
    }
}

enum MemoirRouter: URLRequestConvertible {
    
    case getMemoirList(mogakId: Int, paging: Int, size: Int)
    
    var endPoint: String {
        switch self {
        case .getMemoirList(let mogakId): return "api/mogaks/\(mogakId)/posts"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        default: return HTTPHeaders(["accept": "application/json", "Authorization": accesstoken])
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMemoirList: return .get
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
        case .getMemoirList(mogakId: let mogakId):
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        
        return request
    }
}
