//
//  ApiConstants.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/20.
//

import Foundation

struct ApiConstants {
    static let BaseURL = "https://mogak.shop:8081"
    static let join = BaseURL + "/api/users/join"
    
    static let JogakDailyURL = BaseURL + "/api/modarats/mogaks/jogaks/daily"
    static let JogakRoutineURL = BaseURL + "/api/modarats/mogaks/jogaks/routine"
    static let JogakTodayURL = BaseURL + "/api/modarats/mogaks/jogaks/today"
    
    static let Accesstoken = "Bearer" + " eyJ0eXBlIjoiand0IiwiYWxnIjoiSFMyNTYifQ.eyJ1c2VyUGsiOiIxIiwiaWF0IjoxNjkyNzIyNDEwLCJleHAiOjE3MjQyNTg0MTB9.sqb4ioXK5fTGz7CRzL1ZBZ9yxDvBwIUfY-Azbo3aVuM"
    
}

//MARK: - Reuslt
enum NetworkResult<T>{
    case success(T) //서버 통신 성공했을 때
    case requestErr(T) // 요청 에러 발생했을 때
    case pathErr(T) // 경로 에러 발생했을 때
    case serverErr // 서버의 내부 에러가 발생했을 때
    case networkErr // 네트워크 연결 실패했을 때
}

//MARK: - JogakDaily

struct JogakDaily: Codable {
    let time: String
    let status: String
    let code: String
    let message: String
    let size: Int? //안에 데이터가 있는지 없는지 모름 ㅎㅎ
    let jogaks: [Jogak]? //안에 데이터가 있는지 없는지 모름 ㅎㅎ

    struct Jogak: Codable {
        let jogakId: Int
        let mogakTitle: String
        let category: String
        let title: String

        // Jogak의 CodingKeys 추가
        enum CodingKeys: String, CodingKey {
            case jogakId, mogakTitle, category, title
        }
    }
}
//MARK: - JogakToday

struct JogakToday: Codable {
    let time: String
    let status: String
    let code: String
    let message: String
    let size: Int? //안에 데이터가 있는지 없는지 모름 ㅎㅎ
    let jogaks: [Jogak]? //안에 데이터가 있는지 없는지 모름 ㅎㅎ

    struct Jogak: Codable {
        let jogakId: Int 
        let mogakTitle: String
        let category: String
        let title: String

        // Jogak의 CodingKeys 추가
        enum CodingKeys: String, CodingKey {
            case jogakId, mogakTitle, category, title
        }
    }
}
