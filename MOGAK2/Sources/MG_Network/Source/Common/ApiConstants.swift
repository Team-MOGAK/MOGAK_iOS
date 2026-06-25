//
//  ApiConstants.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/20.
//

import Foundation

struct ApiConstants {
    static var baseURL: String { APIConfig.BaseURL }
    
    static var join: String { baseURL + "/api/users/join" }
}
