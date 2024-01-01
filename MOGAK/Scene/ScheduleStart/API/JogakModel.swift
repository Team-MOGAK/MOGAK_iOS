//
//  ApiConstants.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/20.
//

import Foundation

//MARK: - 조각 일일 조회

struct JogakToday: Codable {
    let time: String
    let status: String
    let code: String
    let message: String
    let size: Int? //안에 데이터가 있는지 없는지 모름 ㅎㅎ
    let dailyJogaks: [Jogak]? //안에 데이터가 있는지 없는지 모름 ㅎㅎ
    
    struct Jogak: Codable {
        let dailyJogakId: Int
        let mogakTitle: String
        let category: String
        let title: String
        
        // Jogak의 CodingKeys 추가
        enum CodingKeys: String, CodingKey {
            case dailyJogakId, mogakTitle, category, title
        }
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
