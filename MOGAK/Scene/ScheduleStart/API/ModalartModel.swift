//
//  ModalartModel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/24.
//

import Foundation

struct ModalartDetailInfo: Codable {
    let time, status, code, message: String?
    let result: ModalartInfo?
}

// MARK: - Result
struct ModalartInfo: Codable {
    let id: Int
    let title, color: String
    let mogakCategory: [MogakCategory]?
    
    enum CodingKeys : String, CodingKey {
        case id
        case title
        case color
        case mogakCategory = "mogakDtoList"
    }
}

// MARK: - MogakDtoList
struct MogakCategory: Codable {
    let title: String
    let bigCategory: BigCategory
    let smallCategory, color: String?
}

// MARK: - BigCategory
struct BigCategory: Codable {
    let id: Int
    let name: String
}

struct ModalartMainData: Codable {
    let id: Int
    let title: String
    let color: String
}

struct ModalartListResponse: Codable {
    let time, status, code, message: String?
    let modalartList: [ModalartList]?
    
    enum CodingKeys: String, CodingKey {
        case time, status, code, message
        case modalartList = "result"
    }
}

struct ModalartList: Codable {
    let id: Int
    var title: String
}


// MARK: - Result
struct DetailMogak: Codable {
    let mogaks: [DetailMogakData]?
    let size: Int?
}

struct DetailMogakResponse: Codable {
    let time, status, code, message: String?
    let result: DetailMogak?
}

// MARK: - Mogak
struct DetailMogakData: Codable {
    let mogakId: Int
    let title, state: String
    let bigCategory: MainCategory
    let smallCategory: String?
    let color: String?
    let startAt, endAt: String?
    
    enum CodingKeys : String, CodingKey {
        case mogakId = "id"
        case title, state, bigCategory, smallCategory, color, startAt, endAt
    }
}

// MARK: - BigCategory
struct MainCategory: Codable {
    let id: Int
    let name: String
}
