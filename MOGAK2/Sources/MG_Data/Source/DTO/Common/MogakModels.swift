//
//  MogakModels.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/23.
//

import Foundation

struct MogakInitModel: Codable {
    let time, status, code, message: String
    let result: MogakResult?
}

struct MogakResult: Codable {
    let mogakId: Int
    let title: String
}

//struct MogakInitModel: Codable {
//    let time, status, code, message: String
//    let result: MogakResult
//}
//
//// MARK: - Result
//struct MogakResult: Codable {
//    let mogakId: Int
//    let title: String
//
//}
