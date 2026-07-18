import Foundation

@MainActor
final class DefaultMG2SocialLoginUseCase: MG2SocialLoginUseCase {
    private let authUseCase: AuthUseCase
    private let appleTokenProvider: MG2SocialTokenProviding
    private let googleTokenProvider: MG2SocialTokenProviding
    private let kakaoTokenProvider: MG2SocialTokenProviding

    init(
        authUseCase: AuthUseCase,
        appleTokenProvider: MG2SocialTokenProviding,
        googleTokenProvider: MG2SocialTokenProviding,
        kakaoTokenProvider: MG2SocialTokenProviding
    ) {
        self.authUseCase = authUseCase
        self.appleTokenProvider = appleTokenProvider
        self.googleTokenProvider = googleTokenProvider
        self.kakaoTokenProvider = kakaoTokenProvider
    }

    func login(provider: MG2SocialLoginProvider) async throws -> MG2AuthSession {
        let token: String
        switch provider {
        case .apple:
            token = try await appleTokenProvider.token()
        case .google:
            token = try await googleTokenProvider.token()
        case .kakao:
            token = try await kakaoTokenProvider.token()
        }
        return try await authUseCase.login(provider: provider, token: token)
    }
}
