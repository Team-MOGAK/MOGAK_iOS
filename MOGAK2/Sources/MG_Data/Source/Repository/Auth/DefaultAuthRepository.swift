import Foundation

final class DefaultAuthRepository: AuthRepository {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func login(provider: MG2SocialLoginProvider, token: String) async throws -> MG2AuthSession {
        let response: MG2AuthLoginResponseDTO = try await networkProvider.request(target: MG2AuthRouter.socialLogin(provider: provider, token: token))
        return response.toDomain()
    }

    /// 400 · 401 · 403 · 404는 리프레시 토큰을 거절한 것이다. 연결 문제 · 5xx는 그대로 던져 세션을 지우지 않게 한다.
    func refresh(refreshToken: String) async throws -> MG2TokenPair {
        do {
            let response: MG2ResponseDTO<MG2TokenPairDTO> = try await networkProvider.request(target: MG2AuthRouter.refresh(refreshToken: refreshToken))
            return response.result.toDomain()
        } catch MG2NetworkError.httpFailure(let statusCode) where [400, 401, 403, 404].contains(statusCode) {
            throw MG2AuthError.sessionExpired
        }
    }

    func logout() async throws {
        try await networkProvider.requestEmpty(target: MG2AuthRouter.logout)
    }

    func withdraw() async throws {
        try await networkProvider.requestEmpty(target: MG2AuthRouter.withdraw)
    }
}
