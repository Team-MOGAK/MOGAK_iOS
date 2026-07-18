//
//  MogakDetailDTO.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/22.
//

import Foundation

struct MG2JogakDetailResponseDTO: Decodable {
    let time, status, code, message: String?
    let result: [MG2JogakDetailDTO]?
}

struct MG2SingleJogakDetailResponseDTO: Decodable {
    let result: MG2JogakDetailDTO?
}

struct MG2JogakDetailDTO: Decodable {
    let jogakID: Int
    let mogakTitle, category, title: String
    let isRoutine: Bool
    let days: [String]?
    let startDate, endDate: String?
    let isAlreadyAdded: Bool?
    let achievements: Int
    let color : String?
    
    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case mogakTitle, category, title, isRoutine, startDate, endDate, days
        case isAlreadyAdded, achievements, color
    }
    
    func toEntity() -> MG2JogakDetailEntity {
        MG2JogakDetailEntity(
            jogakID: jogakID,
            mogakTitle: mogakTitle,
            category: category,
            title: title,
            isRoutine: isRoutine,
            days: MG2APIWeekdayCoding.decode(days),
            startDate: MG2APIDateCoding.decode(startDate),
            endDate: MG2APIDateCoding.decode(endDate),
            isAlreadyAdded: isAlreadyAdded,
            achievements: achievements,
            color: color
        )
    }
}
