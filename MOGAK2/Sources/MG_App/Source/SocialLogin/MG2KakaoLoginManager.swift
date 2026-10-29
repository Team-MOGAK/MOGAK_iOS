import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import UIKit

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

    /// 카카오톡에서 로그인하지 않고 그냥 돌아오면 SDK가 완료를 부르지 않아 로그인 버튼이 계속 돈다.
    /// 돌아오고 1초가 지나도 콜백 URL이 안 왔으면(SDK 대기 핸들러가 남아 있으면) 취소로 끝낸다.
    private static func cancelIfReturnedWithoutLogin(_ completion: @escaping (OAuthToken?, Error?) -> Void) {
        Task {
            for await _ in NotificationCenter.default.notifications(named: UIApplication.willEnterForegroundNotification) { break }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard AuthController.shared.authorizeWithTalkCompletionHandler != nil else { return }
            AuthController.shared.authorizeWithTalkCompletionHandler = nil
            completion(nil, MG2SocialLoginError.cancelled)
        }
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
                Self.cancelIfReturnedWithoutLogin(completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}
