//
//  RegisterUserInfo.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/19.
//

import Foundation

class RegisterUserInfo {
    static let shared = RegisterUserInfo()
    
    var profileImage : String?
    var nickName : String?
    var userName : String?
    var userEmail : String?
    var userJob : String?
    var userRegion : String?
    private init() {}
}
