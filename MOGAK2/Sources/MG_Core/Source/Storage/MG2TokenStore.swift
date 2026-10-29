import Foundation
import Security

enum MG2TokenStore {
    private static let service = "com.team.mogak.mogak2.auth"

    private enum Account {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let userID = "userId"
        static let isRegistered = "isRegistered"
    }

    static var accessToken: String? { load(Account.accessToken) }
    static var refreshToken: String? { load(Account.refreshToken) }
    /// 회원 번호 · 가입 여부도 토큰과 같이 둔다. 앱을 지웠다 깔아도 토큰과 함께 남아 자동 로그인 뒤에도 그대로 쓴다.
    static var userID: Int? { load(Account.userID).flatMap(Int.init) }
    static var isRegistered: Bool? { load(Account.isRegistered).map { $0 == "1" } }

    static func save(accessToken: String, refreshToken: String) {
        save(accessToken, account: Account.accessToken)
        save(refreshToken, account: Account.refreshToken)
    }

    static func saveUser(id: Int, isRegistered: Bool) {
        save(String(id), account: Account.userID)
        save(isRegistered ? "1" : "0", account: Account.isRegistered)
    }

    static func clearSession() {
        [Account.accessToken, Account.refreshToken, Account.userID, Account.isRegistered].forEach(delete)
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
