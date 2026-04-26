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
        do{
            let urlRequest = try target.asURLRequest()
            
            return try await session.request(urlRequest)
                .validate()
                .serializingDecodable(T.self)
                .value
        }catch{
            throw error
        }
    }
    
}
