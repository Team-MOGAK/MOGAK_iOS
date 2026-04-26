//
//  JogakModel.swift
//  MOGAK
//
//  Created by 안세훈 on 1/20/24.
//

import Foundation

//MARK: - 조각 일일 조회
struct JogakDailyCheck: Codable {
    let time, status, code, message: String?
    let result: result?
}
struct result: Codable {
    let size: Int?
    let dailyJogaks: [DailyJogak]?
}
struct DailyJogak: Codable {
    let jogakID,dailyJogakID: Int?
    let mogakTitle, category, title: String?
    let isRoutine, isAchievement: Bool?

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case dailyJogakID = "dailyJogakId"
        case mogakTitle, category, title, isRoutine, isAchievement
    }
}

//MARK: - 조각 조회
struct ScheduleJogakDetailResponse: Codable {
    let time, status, code, message: String?
    let result: [ScheduleJogakDetail]?
}

struct ScheduleJogakDetail: Codable {
    let jogakID: Int
    let mogakTitle, category, title: String
    let isRoutine: Bool
    let days: [String]?
    let isAlreadyAdded: Bool
    let achievements: Int
    let startDate, endDate: String?
    

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case mogakTitle, category, title, isRoutine, days, isAlreadyAdded, achievements, startDate, endDate
    }
}
//MARK: - 일일 조각 시작
struct JogakDailyStartResponse: Codable {
    let time, status, code, message: String
    let result: [JogakDailyStart]?
}

struct JogakDailyStart: Codable {
    let jogakID, dailyJogakID: Int?
    let title, mogakTitle, category: String?
    let isRoutine: Bool?
    let days: [String]?
    let isAchievement: Bool?
    let achievements: Int?

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case dailyJogakID = "dailyJogakId"
        case title, mogakTitle, category, isRoutine, days, isAchievement, achievements
    }
}

//MARK: - 일일 조각 디테일
struct DailyJogakDetail: Codable {
    let time, status, code, message: String?
    let result: DailyJogakDetailResponse?
}

struct DailyJogakDetailResponse: Codable {
    let jogakID: Int?
    let mogakTitle, category, title: String?
    let isRoutine: Bool?
    let days: [String]?
    let achievements: Int?
    let startDate, endDate: String?
    let color : String?

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case mogakTitle, category, title, isRoutine, days, achievements, startDate, endDate, color
    }
}


//MARK: - 조각 실패
struct JogakFail: Codable {
    let time, status, code, message: String?
    let result: JogakFailResponse?
}
struct JogakFailResponse: Codable {
    let jogakID, dailyJogakID: Int
    let title, mogakTitle, category: String
    let isRoutine: Bool
    let days: String?
    let isAchievement: Bool
    let achievements: Int

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case dailyJogakID = "dailyJogakId"
        case title, mogakTitle, category, isRoutine, days, isAchievement, achievements
    }
}

//MARK: - 조각 성공
struct JogakSuccess: Codable {
    let time, status, code, message: String
    let result: JogakSuccessResponse?
}
struct JogakSuccessResponse: Codable {
    let jogakID, dailyJogakID: Int
    let title, mogakTitle, category: String
    let isRoutine: Bool
    let days: String?
    let isAchievement: Bool
    let achievements: Int

    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case dailyJogakID = "dailyJogakId"
        case title, mogakTitle, category, isRoutine, days, isAchievement, achievements
    }
}
//MARK: - 월간 조각 조회
struct JogakMonth: Codable {
    let time, status, code, message: String
    let result: [JogakMonthResult]?
}

struct JogakMonthResult: Codable {
    let dailyJogakID: Int?
    let date: String?
    let isAchievement: Bool?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case dailyJogakID = "dailyJogakId"
        case date, isAchievement, title
    }
}

