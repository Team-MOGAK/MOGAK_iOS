//
//  NetworkProvider.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//

import Foundation
import Alamofire

public protocol NetworkProvider {
    func request<T: Decodable>(target: RequestTarget) async throws -> T
}
