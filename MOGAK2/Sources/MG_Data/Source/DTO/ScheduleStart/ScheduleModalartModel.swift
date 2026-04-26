//
//  ModalartModel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/24.
//

import Foundation

struct ScheduleModalartDetailInfo: Codable {
    let time, status, code, message: String?
    let result: ScheduleModalartInfo?
}

// MARK: - Result
struct ScheduleModalartInfo: Codable {
    let id: Int
    let title, color: String
    let mogakCategory: [ScheduleMogakCategory]?
    
    enum CodingKeys : String, CodingKey {
        case id
        case title
        case color
        case mogakCategory = "mogakDtoList"
    }
}

// MARK: - MogakDtoList
struct ScheduleMogakCategory: Codable {
    let title: String
    let bigCategory: ScheduleBigCategory
    let smallCategory, color: String?
}

// MARK: - BigCategory
struct ScheduleBigCategory: Codable {
    let id: Int
    let name: String
}

struct ScheduleModalartMainData: Codable {
    let id: Int
    let title: String
    let color: String
}

struct ScheduleModalartListResponse: Codable {
    let time, status, code, message: String?
    let modalartList: [ScheduleModalartList]?
    
    enum CodingKeys: String, CodingKey {
        case time, status, code, message
        case modalartList = "result"
    }
}

struct ScheduleModalartList: Codable {
    let id: Int
    let title, color: String
}


// MARK: - Result
struct ScheduleDetailMogak: Codable {
    let mogaks: [ScheduleDetailMogakData]?
    let size: Int?
}

struct ScheduleDetailMogakResponse: Codable {
    let time, status, code, message: String?
    let result: ScheduleDetailMogak?
}

// MARK: - Mogak
struct ScheduleDetailMogakData: Codable {
    let mogakId: Int
    let title: String
    let state: String?
    let bigCategory: ScheduleMainCategory
    let smallCategory: String?
    let color: String?
    let startAt, endAt: String?
    
    enum CodingKeys : String, CodingKey {
        case mogakId = "id"
        case title, state, bigCategory, smallCategory, color, startAt, endAt
    }
}

// MARK: - BigCategory
struct ScheduleMainCategory: Codable {
    let id: Int
    let name: String
}
