import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

@MainActor
final class MG2KakaoLoginManager: MG2SocialTokenProviding {
    private static var nativeAppKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String,
              !value.isEmpty,
              !value.hasPrefix("$(") else {
            return nil
        }
        return value
    }

    @discardableResult
    static func configureSDK() -> Bool {
        guard let nativeAppKey else { return false }
        KakaoSDK.initSDK(appKey: nativeAppKey)
        return true
    }

    @discardableResult
    static func handleOpenURL(_ url: URL) -> Bool {
        guard AuthApi.isKakaoTalkLoginUrl(url) else { return false }
        return AuthController.handleOpenUrl(url: url)
    }

    func token() async throws -> String {
        guard Self.configureSDK() else {
            throw MG2SocialLoginError.configurationMissing(provider: "Kakao")
        }

        return try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let accessToken = token?.accessToken, !accessToken.isEmpty else {
                    continuation.resume(
                        throwing: MG2SocialLoginError.tokenMissing(provider: "Kakao")
                    )
                    return
                }
                continuation.resume(returning: accessToken)
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}
