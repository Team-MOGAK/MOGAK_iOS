//
//  AppleLoginRouter.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/11.
//

import Foundation
import Alamofire

enum LoginRouter: URLRequestConvertible {
    case login(data: LoginRequest)
    case getNewAccessToken(refreshToken: String)
    case logout
    
    var endPoint: String {
        switch self {
        case .login: return "api/auth/login"
        case .getNewAccessToken: return "api/auth/refresh"
        case .logout: return "api/auth/logout"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .getNewAccessToken(let refreshToken):
            return HTTPHeaders(["accept" : "application/json", "Content-Type" : "application/json", "RefreshToken" : refreshToken])
        default: return HTTPHeaders(["accept" : "application/json", "Content-Type" : "application/json"])
        }
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var parameters: Parameters {
        return Parameters()
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = "https://mogak.shop:8080/".appending(endPoint)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = URL(string: url)!
        
        var request = URLRequest(url: urlString)
        request.method = method
        request.headers = headers

        switch self {
        case .login(let data):
            print(#fileID, #function, #line, "- data: \(data)")
            request = try JSONParameterEncoder().encode(data, into: request)
        case .getNewAccessToken:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .logout:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        
        return request
    }
}
