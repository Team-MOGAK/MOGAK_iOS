//
//  APIConfig.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

public enum APIConfig {
    
    private static let baseURL: String = {
        return Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as! String
    }()
    
    private static let testURL: String = {
        return Bundle.main.object(forInfoDictionaryKey: "TEST_URL") as! String
    }()
    
    static let BaseURL: String = {
        return baseURL
    }()
    
    static let TestURL: String = {
        return testURL
    }()
}
