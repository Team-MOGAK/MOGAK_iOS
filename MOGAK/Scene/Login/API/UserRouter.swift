//
//  LoginLouter.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation
import Alamofire

enum UserRouter: URLRequestConvertible {
    case nicknameVerify(nickname: NicknameChangeRequest)
    case userJoin(userData: String) //나중에는 여기로 수정해야 하지만 현재는 따로 빠져있음(userNetwork의 userJoin함수에 전부 들어가있음)
    case nicknameChange(nickname: NicknameChangeRequest)
    case jobChange(job: JobChangeRequest)
    case profileImgChange
    case getUserData
    
    var endPoint: String {
        switch self {
        case .nicknameVerify: return "api/users/nickname/verify"
        case .userJoin: return "api/users/join"
        case .nicknameChange: return "api/users/profile/nickname"
        case .jobChange: return "api/users/profile/job"
        case .profileImgChange: return "api/users/profile/image"
        case .getUserData: return "api/users/profile"
        }
    }
    
    //헤더
    var headers: HTTPHeaders {
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        print(#fileID, #function, #line, "- accessToken: \(accessToken)")
        switch self {
        case .nicknameVerify, .profileImgChange: return HTTPHeaders(["accept":"application/json"])
        case .userJoin: return HTTPHeaders(["accept":"application/json", "Content-Type" : "multipart/form-data"])
//        default: return HTTPHeaders(["Content-Type" : "application/json", "accept":"application/json", "Authorization" : "Bearer \(accessToken)"])
        default: return HTTPHeaders(["Content-Type" : "application/json", "accept":"application/json"])
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUserData: return .get
        case .nicknameVerify, .userJoin: return .post
        case .nicknameChange, .jobChange, .profileImgChange: return .put
        }
    }
    
    var parameters: Parameters {
        return Parameters()
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = "https://mogak.shop:8080/".appending(endPoint)
//        var url = "https://mogak.shop:8081/".appending(endPoint)
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let urlString = URL(string: url)!
        print(#fileID, #function, #line, "- urlString: \(urlString)")
        var request = URLRequest(url: urlString)
        request.method = method
        request.headers = headers
        
        switch self {
        case .nicknameVerify(let nickname):
            request = try JSONParameterEncoder().encode(nickname, into: request)
        case .userJoin(let data):
            request = try JSONParameterEncoder().encode(data, into: request)
        case .nicknameChange(let nickname):
            request = try JSONParameterEncoder().encode(nickname, into: request)
//            request.h
            print(#fileID, #function, #line, "- <#comment#>")
        case .jobChange(let job):
            request = try JSONParameterEncoder().encode(job, into: request)
        case .profileImgChange:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        case .getUserData:
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        
        return request
    }
}
