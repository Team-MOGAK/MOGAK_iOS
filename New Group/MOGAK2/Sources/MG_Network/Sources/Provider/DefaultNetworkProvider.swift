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
    
    public func request<T>(target: any RequestTarget) async throws -> T {
        do{
            
        }catch{
          throw error
        }
    }
    
}
