//
//  APICall.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/08.
//

import Foundation

///API관련
protocol APICall {
    var path: String { get }
    var method: String { get }
    var headers: [String : String]? { get }
    func body() throws -> Data?
}

typealias StatusCode = Int

enum APIError: Error {
    case invalidURL
    case httpCode(StatusCode)
    case unexpectedResponse
//    case imageDeserialization
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "잘못된 URL입니다"
        case .httpCode(let status): return "Unexpected status code: \(status)"
        case .unexpectedResponse: return "서버로 부터 잘못된 응답을 받았습니다."
//        case .imageDeserialization: return ""
        }
    }
}


extension APICall {
    //MARK: - make request
    func urlRequest(baseURL: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else { throw
            APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = try body()
        
        return request
    }
}
