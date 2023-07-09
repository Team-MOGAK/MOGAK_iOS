//
//  AccountAPI.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/24.
//

import Foundation

enum AccountAPI {
    case signIn
    case signUp
    case userInfo
    case check
    case remove
    
    var url: String {
        
        switch self {
        case .signIn: return "\(MOGAKAPI.baseURL)/api/account/signin"
        case .signUp: return "\(MOGAKAPI.baseURL)/api/account/signup"
        case .userInfo: return "\(MOGAKAPI.baseURL)/api/user/info"
        case .check: return "\(MOGAKAPI.baseURL)/api/account/check"
            
            // 탈퇴 시, 토근도 지울 것!
        case .remove: return "\(MOGAKAPI.baseURL)/api/user/secession"
        }
    }
}
