//
//  JoinModel.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/21.
//

import Foundation

struct JoinModel: Codable {
    let now: String?
    let status: Int?
    let code, message: String?
    let userId: Int?
    let nickname: String?
}
