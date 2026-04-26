//
//  APIConfig.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

public enum APIConfig {
    
    private static let baseURL: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("Can't load BASE_URL")
        }
        return value
    }()

    /// 규칙: 당분간 MOGAK1 API를 우선 연결한다.
    static let LegacyBaseURL: String = {
        return baseURL
    }()

    /// MOGAK2 API 전환 시 아래 값으로 교체한다.
    // static let MOGAK2BaseURL: String = {
    //     return baseURL
    // }()

    static let ActiveBaseURL: String = {
        return LegacyBaseURL
    }()
}
