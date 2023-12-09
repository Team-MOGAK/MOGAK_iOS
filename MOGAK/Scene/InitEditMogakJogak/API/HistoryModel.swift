//
//  HistoryModel.swift
//  MOGAK
//
//  Created by 이재혁 on 12/6/23.
//

import Foundation
import Alamofire

struct CreateMogakResponse: Codable {
    let time, status, code, message: String?
    //let result: MogakMainData
    let result: CreateMogakMainData
}

struct MogakMainData: Codable {
    let modaratId: Int
    let title: String
    let bigCategory: String
//    let smallCategory: String
    let startAt: String
    let endAt: String
    let color: String
}

struct CreateMogakMainData: Codable {
    let mogakId: Int
    let title: String
}
