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
    
    ///테스트를 위한 URL이 있다면 사용.
    static let TestURL: String = {
        return baseURL + "/test"
    }()
    
    ///베포용 URL이 있다면 사용.
    static let ReleaseURL: String = {
        return baseURL + "/api"
    }()
}
