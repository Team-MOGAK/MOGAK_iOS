//
//  MogakRouter.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/11.
//

import Foundation
import Alamofire

enum MogakRouter: URLRequestConvertible {
    case getJogakList
    
    var endPoint: String {
        switch self {
        case .getJogakList: return "api/mogak"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .getJogakList: return HTTPHeaders(["accept":"application/json", "Authorization" : accesstoken])
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getJogakList: return .get
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
        case .getJogakList:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        
        return request
    }
}
