//
//  Networking_ServerResponseStruct.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/08/22.
//

import Foundation

// 네트워킹(페이스메이커) 게시글 리스트 불러오기
struct PacemakerFeedsResponse: Codable {
    let time, status, code, message: String
    let result: [Result]
    
    
    // MARK: - Result
    struct Result: Codable {
        let user: User
        let contents: String
        let imgUrls: [String]
        let comments: [Comment]
        let likeCnt, viewCnt: Int
    }
    
    // MARK: - Comment
    struct Comment: Codable {
        let commentId: Int
        let nickname, contents, createdAt: String
    }
    
    // MARK: - User
    struct User: Codable {
        let nickname, job, address: String
    }
    
}

