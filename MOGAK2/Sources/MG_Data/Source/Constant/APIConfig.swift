//
//  APIConfig.swift
//  MOGAK
//
//  Created by 안세훈 on 4/12/26.
//

import Foundation

public enum APIConfig {

    private static func infoString(_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            assertionFailure("[APIConfig] Missing Info.plist key: \(key)")
            return ""
        }
        return value
    }

    static let BaseURL: String = infoString("BASE_URL")

    static let TestURL: String = infoString("TEST_URL")

    /// Apple refresh-token revoke endpoint (Cloud Function). Overridable via `APPLE_REVOKE_URL`.
    static let appleRevokeURL: String = {
        if let value = Bundle.main.object(forInfoDictionaryKey: "APPLE_REVOKE_URL") as? String, !value.isEmpty {
            return value
        }
        return "https://us-central1-pickdrink-492de.cloudfunctions.net/revokeToken"
    }()
}
