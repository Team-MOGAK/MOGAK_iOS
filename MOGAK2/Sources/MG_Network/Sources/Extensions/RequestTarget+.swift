//
//  RequestTarget+.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//

import Foundation
import Alamofire

extension RequestTarget {
    
    func asURLRequest() throws -> URLRequest {
        do {
            let url = try (baseURL + path).asURL()
            
            var request = try URLRequest(url: url, method: HTTPMethod(rawValue: method.rawValue))
            
            if let headers = headers {
                request.headers = HTTPHeaders(headers)
            }
            if let query = query, !query.isEmpty {
                request = try URLEncoding.default.encode(request, with: query)
            }
            
            if let body = body {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            return request
            
        } catch {
            throw error
        }
    }
}
