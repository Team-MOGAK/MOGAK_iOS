//
//  LoginModel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/30.
//

import Foundation

struct UserInfo: Codable {
    let uid: String
    let email: String?
    var nickName: String?
    let profileImg: URL?

    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case nickName
        case profileImg
    }
}


struct SignInWithAppleResult {
    let token: String
    let nonce: String
}

struct LoginRequest: Codable {
    let idToken: String
    
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

struct LoginFailResponse: Codable {
    let time, code, message: String?
    let status: Int
}

// MARK: - Welcome
struct LoginResponse: Codable {
//    let time, status, code, message: String?
    let time, code, message: String?
    let status: String
    let result: LoginRealData?
}

// MARK: - Result
struct LoginRealData: Codable {
    let isRegistered: Bool
    let userID: Int
    let tokens: Tokens

    enum CodingKeys: String, CodingKey {
        case isRegistered
        case userID = "userId"
        case tokens
    }
}

struct RefreshTokenResponse: Codable {
//    let time, status, code, message: String?
    let time, code, message: String?
    let status: String
    let result: Tokens?
}

// MARK: - Tokens
struct Tokens: Codable {
    let accessToken, refreshToken: String
}

struct LogoutResponse: Codable {
    let time, status, code, message: String
    let result: String?
}

struct WithDrawResponse: Codable {
    let time, code, message, status: String
    let result: WithDrawResult
}

struct WithDrawResult: Codable {
    let deleted: Bool
}

struct WithDrawErrorResponse: Codable {
    let time, code, message: String
    let status: Int
}
