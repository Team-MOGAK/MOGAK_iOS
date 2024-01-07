//
//  ApiConstants.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/20.
//

import Foundation

//MARK: - 조각 일일 조회
struct JogakDailyCheck: Codable {
    let time, status, code, message: String
    let result: result
}
struct result: Codable {
    let size: Int
    let dailyJogaks: [DailyJogak]
}
struct DailyJogak: Codable {
    let dailyJogakID: Int
    let mogakTitle, category, title: String
    let isRoutine, isAchievement: Bool

    enum CodingKeys: String, CodingKey {
        case dailyJogakID = "dailyJogakId"
        case mogakTitle, category, title, isRoutine, isAchievement
    }
}
//MARK: - 조각 조회

struct JogakDetailResponse: Codable {
    let time, status, code, message: String?
    let result: [JogakDetail]?
}

struct JogakDetail: Codable {
    let jogakID: Int
    let mogakTitle, category, title: String
    let isRoutine: Bool
    let days: [String]?
    let startDate, endDate: String?

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case mogakTitle, category, title, isRoutine, startDate, endDate, days
    }
}
