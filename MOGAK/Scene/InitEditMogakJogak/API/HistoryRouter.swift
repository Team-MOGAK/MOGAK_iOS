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
    
    var endPoint: String {
        switch self {
        case .createMogak: return "api/modarats/mogaks"
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
        }
        
        return request
    }
}
