import Foundation

protocol MG2SessionStoring {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var isFirstTime: Bool { get }
    var storedUserIsRegistered: Bool? { get }

    func saveSession(accessToken: String, refreshToken: String, userID: Int, isRegistered: Bool)
    func saveTokens(accessToken: String, refreshToken: String)
    func setFirstTime(_ isFirstTime: Bool)
    func setUserIsRegistered(_ isRegistered: Bool)
    func clearAuthentication()
    func resetAfterWithdrawal()
}

final class MG2SessionStore: MG2SessionStoring {
    private enum Key {
        static let userID = "userId"
    }

    var accessToken: String? { MG2TokenStore.accessToken }
    var refreshToken: String? { MG2TokenStore.refreshToken }
    var isFirstTime: Bool { MG2LaunchStorage.isFirstTime }
    var storedUserIsRegistered: Bool? { MG2LaunchStorage.storedUserIsRegistered }

    init() {}

    func saveSession(accessToken: String, refreshToken: String, userID: Int, isRegistered: Bool) {
        saveTokens(accessToken: accessToken, refreshToken: refreshToken)
        UserDefaults.standard.set(userID, forKey: Key.userID)
        setUserIsRegistered(isRegistered)
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        MG2TokenStore.save(accessToken: accessToken, refreshToken: refreshToken)
    }

    func setFirstTime(_ isFirstTime: Bool) {
        MG2LaunchStorage.setFirstTime(isFirstTime)
    }

    func setUserIsRegistered(_ isRegistered: Bool) {
        MG2LaunchStorage.setUserIsRegistered(isRegistered)
    }

    func clearAuthentication() {
        MG2TokenStore.clearTokens()
        MG2LaunchStorage.clearUserRegistration()
        UserDefaults.standard.removeObject(forKey: Key.userID)
    }

    func resetAfterWithdrawal() {
        MG2TokenStore.clearTokens()
        MG2LaunchStorage.resetAfterWithdrawal()
        UserDefaults.standard.removeObject(forKey: Key.userID)
    }
}
