//
//  FeedModel.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/08/23.
//

import Foundation

struct FeedModel: Codable {
    var userName: String
    var category: String
    var feedImageURL: String
    var feedContent: String
    var likeCnt: Int
    var messageCnt: Int
}
