//
//  MogakDetailModel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/22.
//

import Foundation

struct JogakDetailResponse: Codable {
    let time, status, code, message: String?
    let result: [JogakDetail]?
}

// MARK: - Result
struct JogakDetail: Codable {
    let jogakID: Int
    let mogakTitle, category, title: String
    let isRoutine: Bool
    let days: [String]?
    //let achievements: Int
    let startDate, endDate: String?
    let isAlreadyAdded: Bool?
    let achievements: Int
    let color : String?
    
    enum CodingKeys: String, CodingKey {
        case jogakID = "jogakId"
        case mogakTitle, category, title, isRoutine, startDate, endDate, days
        case isAlreadyAdded, achievements, color
    }
    
    var daysSetting: [String]? {
        var tempDays: [String] = Array(repeating: "", count: 7)
        guard let days = days else { return [] }
        for day in days {
            switch day {
            case "MONDAY": tempDays[0] = "월"
            case "TUESDAY": tempDays[1] = "화"
            case "WEDNESDAY": tempDays[2] = "수"
            case "THURSDAY": tempDays[3] = "목"
            case "FRIDAY": tempDays[4] = "금"
            case "SATURDAY": tempDays[5] = "토"
            case "SUNDAY": tempDays[6] = "일"
            default: ""
            }
        }
        
        return tempDays.filter { day in
            return day != ""
        }
    }
}

struct MogakDeleteResponse: Codable {
    let time, status, code, message: String?
    let result: String?
}
