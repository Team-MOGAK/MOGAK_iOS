//
//  LoginModel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/30.
//

import Foundation

struct UserInfo: Codable {
    let uid: String
    let email: String?
    var nickName: String?
    let profileImg: URL?

    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case nickName
        case profileImg
    }
}
