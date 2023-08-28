//
//  ScheduleStartStruct.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/22.
//

import Foundation


struct APIconstants{
    static let BaseURL = "http://43.200.36.231:8080/"
    static let GenerateJogakURL = "/api/mogaks/jogaks/{mogakId}"    //생성
    static let DeleteJogakURL = "/api/mogaks/jogaks/{jogakId}"      //삭제
    static let JogakStartURL = BaseURL + "/api/mogaks/jogaks/{jogakId}/start" //시작
    static let JohakEndURL = BaseURL + "/api/mogaks/jogaks/{jogakId}/end" //종료
}
//MARK: - 결과
enum CheckJogakResponse <T>{
  case success(T) //서버 통신 성공했을 때
  case requestErr(T) // 요청 에러 발생했을 때
  case pathErr(T) // 경로 에러 발생했을 때
  case serverErr // 서버의 내부 에러가 발생했을 때
  case networkFail // 네트워크 연결 실패했을 때
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

//MARK: - 당일 조각 조회
struct CheckJogak: Codable {
    let time, status, code, message: String
    let result: Result
}

struct Result: Codable {
    let jogaks: [Jogak]
    let size: Int
}

struct Jogak: Codable {
    let mogakTitle, startTime, endTime: String
}

struct noUser: Codable {
    let time: String
    let status: Int
    let code, message: String
}


