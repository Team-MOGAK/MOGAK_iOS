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
    //let smallCategory: String
    let startAt: String
    let endAt: String
    let color: String
}

struct CreateMogakMainData: Codable {
    let mogakId: Int
    let title: String
}

struct EditMogakResponse: Codable {
    let time, status, code, message: String?
    let result: EditMogakMainData
}

struct EditMogakMainData: Codable {
    let mogakId: Int
    let title: String
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
