//
//  NetworkProvider.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//

import Foundation
import Alamofire

public protocol NetworkProvider {
    func request<T: Decodable>(target: URLRequestConvertible) async throws -> T
    func requestEmpty(target: URLRequestConvertible) async throws
}
