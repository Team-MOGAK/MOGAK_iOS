//
//  LoginLouter.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation
import Alamofire

enum UserRouter: URLRequestConvertible {
    case nicknameVerify(nickname: String)
    case userJoin(userData: String)
    case nicknameChange(nickname: String)
    case jobChange(job: String)
    case profileImgChange
    
    var endPoint: String {
        switch self {
        case .nicknameVerify(let nickname): return "api/users/\(nickname)/verify"
        case .userJoin: return "api/users/join"
        case .nicknameChange: return "api/user/profile/nickname"
        case .jobChange: return "api/user/profile/job"
        case .profileImgChange: return "api/user/profile/image"
        }
    }
    
    //헤더
    var headers: HTTPHeaders {
        switch self {
        case .nicknameVerify, .profileImgChange: return HTTPHeaders(["accept":"application/json"])
        case .userJoin: return HTTPHeaders(["accept":"application/json", "Content-Type" : "multipart/form-data"])
        default: return HTTPHeaders(["accept":"application/json", "Authorization" : accesstoken])
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .nicknameVerify, .userJoin: return .post
        case .nicknameChange, .jobChange, .profileImgChange: return .put
        }
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
        case .nicknameVerify:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .userJoin(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        case .nicknameChange(let nickname):
            request = try JSONParameterEncoder().encode(nickname, into: request)
        case .jobChange(let job):
            request = try JSONParameterEncoder().encode(job, into: request)
        case .profileImgChange:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        return request
    }
}
