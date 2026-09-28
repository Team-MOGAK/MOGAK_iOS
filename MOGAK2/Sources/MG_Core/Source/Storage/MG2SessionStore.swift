import Foundation
import Security

final class MG2SessionStore: SessionStorage {
    private enum Key {
        static let userID = "userId"
    }

    // 키체인은 앱을 지워도 남는다. 재설치 후 같은 계정으로 로그인하면 서버 없이 프로필 이미지가 복원된다.
    private static let profileImageService = "com.team.mogak.mogak2.profileImage"

    var accessToken: String? { MG2TokenStore.accessToken }
    var refreshToken: String? { MG2TokenStore.refreshToken }
    var isFirstTime: Bool { MG2LaunchStorage.isFirstTime }
    var storedUserIsRegistered: Bool? { MG2LaunchStorage.storedUserIsRegistered }

    var profileImageID: Int? {
        guard let userID else { return nil }
        return MG2Keychain.load(service: Self.profileImageService, account: String(userID)).flatMap(Int.init)
    }

    private var userID: Int? {
        UserDefaults.standard.object(forKey: Key.userID) as? Int
    }

    func saveProfileImageID(_ imageID: Int) {
        guard let userID else { return }
        MG2Keychain.save(String(imageID), service: Self.profileImageService, account: String(userID), accessibility: kSecAttrAccessibleAfterFirstUnlock)
    }

    func saveSession(tokens: MG2TokenPair, userID: Int, isRegistered: Bool) {
        saveTokens(tokens)
        UserDefaults.standard.set(userID, forKey: Key.userID)
        MG2LaunchStorage.setUserIsRegistered(isRegistered)
    }

    func saveTokens(_ tokens: MG2TokenPair) {
        MG2TokenStore.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
    }

    func setFirstTime(_ isFirstTime: Bool) {
        MG2LaunchStorage.setFirstTime(isFirstTime)
    }

    func clearAuthentication() {
        MG2TokenStore.clearTokens()
        MG2LaunchStorage.clearUserRegistration()
        UserDefaults.standard.removeObject(forKey: Key.userID)
    }

    func resetAfterWithdrawal() {
        if let userID {
            MG2Keychain.delete(service: Self.profileImageService, account: String(userID))
        }
        MG2TokenStore.clearTokens()
        MG2LaunchStorage.resetAfterWithdrawal()
        UserDefaults.standard.removeObject(forKey: Key.userID)
    }
}
