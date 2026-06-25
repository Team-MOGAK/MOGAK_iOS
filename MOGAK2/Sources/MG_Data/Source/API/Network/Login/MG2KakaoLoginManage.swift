//import Foundation
//import KakaoSDKAuth
//import KakaoSDKCommon
//import KakaoSDKUser
//
//final class MG2KakaoLoginManage {
//    static var nativeAppKey: String {
//        Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String ?? ""
//    }
//
//    private let authUseCase: AuthUseCase
//
//    init(authUseCase: AuthUseCase) {
//        self.authUseCase = authUseCase
//    }
//
//    static func configureSDK() {
//        guard !nativeAppKey.isEmpty else {
//            print("[KakaoLogin] KAKAO_NATIVE_APP_KEY is missing")
//            return
//        }
//        KakaoSDK.initSDK(appKey: nativeAppKey)
//    }
//
//    @MainActor
//    @discardableResult
//    static func handleOpenUrl(_ url: URL) -> Bool {
//        guard AuthApi.isKakaoTalkLoginUrl(url) else { return false }
//        return AuthController.handleOpenUrl(url: url)
//    }
//
//    @MainActor
//    func startKakaoLogin() {
//        Self.configureSDK()
//
//        let completion: (OAuthToken?, Error?) -> Void = { [weak self] token, error in
//            guard let self else { return }
//
//            if let error {
//                print("[KakaoLogin] sign in failed: \(error.localizedDescription)")
//                return
//            }
//
//            guard let accessToken = token?.accessToken, !accessToken.isEmpty else {
//                print("[KakaoLogin] access token is missing")
//                return
//            }
//
//            Task {
//                do {
//                    let session = try await self.authUseCase.login(provider: .kakao, token: accessToken)
//                    MG2SocialLoginSessionStore.apply(session: session)
//                } catch {
//                    print("[KakaoLogin] backend login failed: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        if UserApi.isKakaoTalkLoginAvailable() {
//            UserApi.shared.loginWithKakaoTalk(completion: completion)
//        } else {
//            UserApi.shared.loginWithKakaoAccount(completion: completion)
//        }
//    }
//}
