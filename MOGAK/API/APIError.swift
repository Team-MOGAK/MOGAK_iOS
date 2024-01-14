//
//  APICall.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/08.
//

typealias StatusCode = Int

enum APIError: Error, Equatable {
    case invalidURL
    case httpCode(StatusCode)
    case unexpectedResponse
    case NotExistUser(String) //존재하지 않는 유저 - 404(닉네임 변경)
    case NotExistJob(String) //존재하지 않는 직업
//    case invalidNickname(String) //올바르지 않는 닉네임
    case invalidNickname //올바르지 않는 닉네임
//    case imageDeserialization
}

