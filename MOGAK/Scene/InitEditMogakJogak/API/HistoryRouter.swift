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
    case editMogak(data: MogakMainData)
    
    var endPoint: String {
        switch self {
        case .createMogak, .editMogak: return "api/modarats/mogaks"
        case .deleteMogak(let mogakId): return "api/modarats/mogaks/\(mogakId)"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        default: return HTTPHeaders(["accept": "application/json", "Authorization": accesstoken])
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createMogak: return .post
        case .deleteMogak: return .delete
        case .editMogak: return .put
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
