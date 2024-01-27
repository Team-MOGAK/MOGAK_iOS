//
//  HistoryModel.swift
//  MOGAK
//
//  Created by 이재혁 on 12/6/23.
//

import Foundation
import Alamofire

struct CreateMogakResponse: Codable {
    let time, status, code, message: String?
    //let result: MogakMainData
    let result: CreateMogakMainData
}

struct MogakMainData: Codable {
    let modaratId: Int
    let title: String
    let bigCategory: String
    let smallCategory: String?
    //let startAt: String
    //let endAt: String
    let color: String
}

struct CreateMogakMainData: Codable {
//    let mogakId: Int
//    let title: String
    let id: Int
    let title: String
    //let state: String?
    let bigCategory: BigCategory
    let smallCategory: String?
    let color: String?
    //let startAt: String
    //let endAt: String
}

// MARK: - 모각수정 Response
struct EditMogakResponse: Codable {
    let time, status, code, message: String?
    let result: EditMogakMainData
}

struct EditMogakMainData: Codable {
    let id: Int
    let title: String
    let bigCategory: BigCategory
    let smallCategory: String?
    let color: String
}

// MARK: - 모각수정 Request body
struct EditMogakRequestMainData: Codable {
    let mogakId: Int
    let title: String
    let bigCategory: String
    let smallCategory: String?
    //let startAt: String
    //let endAt: String
    let color: String
}

// MARK: - 모각삭제 Response
struct DeleteMogakResponse: Codable {
    let time, status, code, message, result: String?
}

// MARK: - 조각생성 Request body
struct CreateJogakRequestMainData: Codable {
    let mogakId: Int
    let title: String
    let isRoutine: Bool
    let days: [String]?
    let today: String?
    let endDate: String?
}

// MARK: - 조각생성 Response
struct CreateJogakResponse: Codable {
    let time, status, code, message: String?
    let result: CreateJogakMainData
}

struct CreateJogakMainData: Codable {
    let jogakId: Int
    let mogakTitle: String
    let category: String
    let title: String
    let isRoutine: Bool
    let startDate: String?
    let endDate: String?
}

// MARK: - 조각수정 Request body
struct EditJogakRequestMainData: Codable {
    let title: String
    let isRoutine: Bool
    let days: [String]?
    let endDate: String?
}

// MARK: - 조각수정 Response
struct EditJogakResponse: Codable {
    let time, status, code, message: String?
}

// MARK: - 회고록 조회 Response
struct MemoirListResponse: Codable {
    let time, status, code, message: String?
    let memoirListResult: MemoirListResult?
    
    enum CodingKeys: String, CodingKey {
        case time, status, code, message
        case memoirListResult = "result"
    }
}

struct MemoirListResult: Codable {
    let content: [MemoirContent]
    let pageable: MemoirPageable
    let number: Int
    let sort: MemoirSort
    let size, numberOfElements: Int
    let first, last, empty: Bool
}

struct MemoirContent: Codable {
    let postId, mogakId: Int
    let contents: String
    let thumbnailUrl: String
    let likeCnt: Int
}

struct MemoirPageable: Codable {
    let sort: MemoirSort
    let offset, pageNumber, pageSize: Int
    let paged, unpaged: Bool
}

struct MemoirSort: Codable {
    let empty, unsorted, sorted: Bool
}
