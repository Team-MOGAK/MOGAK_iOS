import Foundation

@MainActor
final class MG2SocialTokenProvider: SocialTokenProvider {
    private let appleLoginManager = MG2AppleLoginManager()
    private let googleLoginManager = MG2GoogleLoginManager()
    private let kakaoLoginManager = MG2KakaoLoginManager()

    func token(for provider: MG2SocialLoginProvider) async throws -> String {
        switch provider {
        case .apple:
            return try await appleLoginManager.token()
        case .google:
            return try await googleLoginManager.token()
        case .kakao:
            return try await kakaoLoginManager.token()
        }
    }
}
