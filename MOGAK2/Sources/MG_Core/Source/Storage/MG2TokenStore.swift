import Foundation
import Security

enum MG2TokenStore {
    private static let service = "com.team.mogak.mogak2.auth"

    private enum Account {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }

    static var accessToken: String? { load(Account.accessToken) }
    static var refreshToken: String? { load(Account.refreshToken) }

    static func save(accessToken: String, refreshToken: String) {
        save(accessToken, account: Account.accessToken)
        save(refreshToken, account: Account.refreshToken)
    }

    static func clearTokens() {
        delete(Account.accessToken)
        delete(Account.refreshToken)
    }

    private static func save(_ value: String, account: String) {
        MG2Keychain.save(value, service: service, account: account, accessibility: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    }

    private static func load(_ account: String) -> String? {
        MG2Keychain.load(service: service, account: account)
    }

    private static func delete(_ account: String) {
        MG2Keychain.delete(service: service, account: account)
    }
}
