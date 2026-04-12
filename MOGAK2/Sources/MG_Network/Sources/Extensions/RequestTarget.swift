//
//  RequestTarget.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//

import Foundation
import Alamofire

public protocol RequestTarget: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var query: [String: Any]? { get }
    var body: [String: Any]? { get }
}

extension RequestTarget {
    
    //    //릴리즈 url
    //    var baseURL: String {
    //        return "\(APIConfig.ReleaseURL)"
    //    }
    
    //테스트 url
    var baseURL: String {
        return "\(APIConfig.TestURL)"
    }
    
    var headers: [String: String]? { return nil }
    var query: [String: Any]? { return nil }
    var body: [String: Any]? { return nil }
    
    public func asURLRequest() throws -> URLRequest {
        do {
            let url = try (baseURL + path).asURL()
            var request = try URLRequest(url: url, method: HTTPMethod(rawValue: method.rawValue))
            
            if let headers = headers {
                request.headers = HTTPHeaders(headers)
            }
            
            if let query = query, !query.isEmpty {
                request = try URLEncoding.default.encode(request, with: query)
            }
            
            if let body = body, !body.isEmpty {
                request = try JSONEncoding.default.encode(request, with: body)
            }
            
            return request
        } catch {
            throw error
        }
    }
}
