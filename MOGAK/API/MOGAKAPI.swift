//
//  MOGAKAPI.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import Foundation

enum MOGAKAPI {
    
    static let baseURL: String = "http://43.200.36.231:8080/ "
    
    enum Header: APIHeader {
        
        static let authFieldName: String = "Authorization"
        
        case auth(String)
        case contentMulti
        
        var key: String {
            
            switch self {
            case .auth: return MOGAKAPI.Header.authFieldName
            case .contentMulti: return "Content-Type"
            }
        }
        
        var value: String {
            
            switch self {
            case .auth(let value): return "Bearer \(value)"
            case .contentMulti:return "multipart/form-data; boundary=\(APIConst.boundary)"
            }
        }
    }
}
