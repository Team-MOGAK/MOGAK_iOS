import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

@MainActor
final class MG2KakaoLoginManager {
    private static var nativeAppKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String, !value.isEmpty, !value.hasPrefix("$(") else { return nil }
        return value
    }

    @discardableResult
    static func configureSDK() -> Bool {
        guard let nativeAppKey else { return false }
        KakaoSDK.initSDK(appKey: nativeAppKey)
        return true
    }

    static func handleOpenURL(_ url: URL) -> Bool {
        guard AuthApi.isKakaoTalkLoginUrl(url) else { return false }
        return AuthController.handleOpenUrl(url: url)
    }

    /// 로그인 창을 닫았거나(Cancelled) 동의 화면에서 취소한(AccessDenied) 경우
    private static func isCancelled(_ error: Error) -> Bool {
        guard let error = error as? SdkError else { return false }
        if error.isClientFailed { return error.getClientError().reason == .Cancelled }
        if error.isAuthFailed { return error.getAuthError().reason == .AccessDenied }
        return false
    }

    func token() async throws -> String {
        guard Self.configureSDK() else { throw MG2SocialLoginError.configurationMissing(provider: "Kakao") }

        return try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error {
                    continuation.resume(throwing: Self.isCancelled(error) ? MG2SocialLoginError.cancelled : error)
                    return
                }
                guard let accessToken = token?.accessToken, !accessToken.isEmpty else {
                    continuation.resume(throwing: MG2SocialLoginError.tokenMissing(provider: "Kakao"))
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
