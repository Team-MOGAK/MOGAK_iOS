//
//  ValidateNicknameModel.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/20.
//

import Foundation

struct ValidateNicknameModel: Codable {
    let time: String
    let status: String
    let code, message: String
}
