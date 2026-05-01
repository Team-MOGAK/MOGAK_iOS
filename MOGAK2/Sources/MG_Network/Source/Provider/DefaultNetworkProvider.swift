//
//  DefaultNetworkProvider.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//

import Foundation
import Alamofire

public struct DefaultNetworkProvider: NetworkProvider {
    
    private let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    public func request<T>(target: URLRequestConvertible) async throws -> T where T : Decodable {
        let urlRequest = try target.asURLRequest()
        let response = await session.request(urlRequest).serializingData().response

        let statusCode = response.response?.statusCode ?? -1
        let url = response.request?.url?.absoluteString ?? "unknown-url"
        let responseBody = String(data: response.data ?? Data(), encoding: .utf8) ?? ""

        if let error = response.error {
            print("[Network][Error] \(url)")
            print("[Network][Status] \(statusCode)")
            print("[Network][Body] \(responseBody)")
            throw error
        }

        guard (200..<300).contains(statusCode) else {
            print("[Network][Non2xx] \(url)")
            print("[Network][Status] \(statusCode)")
            print("[Network][Body] \(responseBody)")
            throw NSError(
                domain: "NetworkProvider",
                code: statusCode,
                userInfo: [NSLocalizedDescriptionKey: responseBody]
            )
        }

        let data = response.data ?? Data()
        return try JSONDecoder().decode(T.self, from: data)
    }
    
}
