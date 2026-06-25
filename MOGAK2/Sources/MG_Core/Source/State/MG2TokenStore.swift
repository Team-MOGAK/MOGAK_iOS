import Foundation
import Security

enum MG2TokenStore {
    private static let service = "com.team.mogak.mogak2.auth"

    private enum Account {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }

    static var accessToken: String? {
        load(Account.accessToken) ?? migrateLegacyTokenIfNeeded(account: Account.accessToken)
    }

    static var refreshToken: String? {
        load(Account.refreshToken) ?? migrateLegacyTokenIfNeeded(account: Account.refreshToken)
    }

    static func save(accessToken: String, refreshToken: String) {
        save(accessToken, account: Account.accessToken)
        save(refreshToken, account: Account.refreshToken)
        removeLegacyToken(Account.accessToken)
        removeLegacyToken(Account.refreshToken)
        setCachedAccessToken(accessToken)
    }

    static func clearTokens() {
        delete(Account.accessToken)
        delete(Account.refreshToken)
        removeLegacyToken(Account.accessToken)
        removeLegacyToken(Account.refreshToken)
        setCachedAccessToken(nil)
    }

    private static func save(_ value: String, account: String) {
        guard !value.isEmpty, let data = value.data(using: .utf8) else {
            delete(account)
            return
        }

        delete(account)

        var query = baseQuery(account: account)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func load(_ account: String) -> String? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private static func delete(_ account: String) {
        SecItemDelete(baseQuery(account: account) as CFDictionary)
    }

    private static func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    private static func migrateLegacyTokenIfNeeded(account: String) -> String? {
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: account), !token.isEmpty else {
            removeLegacyToken(account)
            return nil
        }

        save(token, account: account)
        removeLegacyToken(account)

        if account == Account.accessToken {
            setCachedAccessToken(token)
        }

        return token
    }

    private static func removeLegacyToken(_ account: String) {
        UserDefaults.standard.removeObject(forKey: account)
    }

    private static func setCachedAccessToken(_ accessToken: String?) {
        let update = {
            RegisterUserInfo.shared.userAccessToken = accessToken ?? ""
        }

        if Thread.isMainThread {
            update()
        } else {
            DispatchQueue.main.async(execute: update)
        }
    }
}
