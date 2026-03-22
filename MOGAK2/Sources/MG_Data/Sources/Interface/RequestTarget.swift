//
//  RequestTarget.swift
//  MOGAK
//
//  Created by 안세훈 on 3/22/26.
//

import Foundation
import Alamofire

public protocol RequestTarget {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
    var query: [String: Any]? { get }
}
