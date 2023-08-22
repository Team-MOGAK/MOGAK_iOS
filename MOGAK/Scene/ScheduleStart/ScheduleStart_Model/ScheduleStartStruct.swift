//
//  ScheduleStart_ServerRespone.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/22.
//

import Foundation


struct APIconstants{
    static let BaseURL = "http://43.200.36.231:8080/"
    static let GenerateJogakURL = "/api/mogaks/jogaks/{mogakId}"
    static let DeleteJogakURL = "/api/mogaks/jogaks/{jogakId}"
    static let JogakStartURL = BaseURL + "/api/mogaks/jogaks/{jogakId}/start"
    static let JohakEndURL = BaseURL + "/api/mogaks/jogaks/{jogakId}/end"
}

//MARK: - Reuslt
enum NetworkReult<T>{
    case success(T) //서버 통신 성공했을 때
    case requestErr(T) // 요청 에러 발생했을 때
    case pathErr(T) // 경로 에러 발생했을 때
    case serverErr // 서버의 내부 에러가 발생했을 때
    case networkFail // 네트워크 연결 실패했을 때
}

//MARK: - (임시)조각 생성
struct GenerateJogak: Codable {
    let time, status, code, message: String
    let result: GenerateJogakResult
}

struct GenerateJogakResult: Codable {
    let startTime: String
}

//MARK: - 진행중인 모각만 조각을 생성, 존재하지 않는 모각
struct GenerateJogakerror: Codable {
    let time: String
    let status: Int
    let code, message: String
}

//MARK: - (임시)조각 삭제
struct DeleteJogak: Codable {
    let time, status, code, message: String
    let result: String
}

//MARK: - 존재하지 않는 조각,
struct DeleteJogakerror: Codable {
    let time: String
    let status: Int
    let code, message: String
}

//MARK: - 조각 시작
struct JogakStart : Codable{
    let time,status,code,message : String
    let result : JogakStartResult
}

struct JogakStartResult : Codable {
    let title, startTime : String
}

//MARK: - 자정을 넘어서 조각 시작, 존재하지 않는 조각, 이미 시작한 조각
struct JogakStarterror : Codable {
    let time: String
    let status: Int
    let code, message: String
}

//MARK: - 조각 종료
struct JogakEnd : Codable {
    let time, status, code, message: String
    let result: JogakEndResult
}

struct JogakEndResult : Codable {
    let title, startTime, endTime: String
}

//MARK: - 시작하지 않은 조각, 기한을 넘긴 조각, 존재하지 않는 조각, 이미 종료한 조각
struct JogkaEnderror: Codable {
    let time: String
    let status: Int
    let code, message: String
}

