//
//  UserModel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation

struct NicknameVerify: Codable {
    let time: String?
    let status: Int?
    let code, message: String
}

struct UserInfoData: Codable {
    let nickname, job, address, email: String
    let multipartFile: String
}
