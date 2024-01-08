//
//  UserModel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/20.
//

import Foundation

struct NicknameVerify: Codable {
    let time: String?
    let status: Int?
    let code, message: String
}

struct UserInfoData: Codable {
    let nickname, job, address, email: String
    let multipartFile: String
}

struct UserInfoDataResponse: Codable {
    let time: String
    let status: String
    let code: String
    let message: String
    let result: UserInfoDataResponseDetail
}

struct UserInfoDataResponseDetail: Codable {
    let userId: Int
    let nickname: String
}

struct UserInfoChangeResponse: Codable {
    let time, status, code, message: String?
    let result: String?
}

struct NicknameChangeRequest: Codable {
    let nickname: String
}

struct NicknameChangeReponseWithError: Codable {
    let time, code, message: String?
    let status: Int
}

struct NicknameChangeResponse: Codable {
    let time, code, message: String?
    let status: String
}

struct JobChange: Codable {
    let job: String
}

struct JobChangeRequest: Codable {
    let job: String
}

struct ChangeSuccessResponse: Codable {
    let time, status, code, message: String?
    let result: String?
}

struct ChangeErrorResponse: Codable {
    let time: String?
    let status: Int?
    let code, message: String?
}

struct GetUserDataSuccessResponse: Codable {
    let time, status, code, message: String
    let result: UserRealData
}

struct GetUserDataFailureResponse: Codable {
    let time, code, message: String
    let status: Int
}

// MARK: - Result
struct UserRealData: Codable {
    let nickname, job: String
    let imgURL: String?

    enum CodingKeys: String, CodingKey {
        case nickname, job
        case imgURL = "imgUrl"
    }
}
