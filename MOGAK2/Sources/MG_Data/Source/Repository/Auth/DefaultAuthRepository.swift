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

    func refresh(refreshToken: String) async throws -> MG2TokenPair {
        let response: MG2ResponseDTO<MG2TokenPairDTO> = try await networkProvider.request(target: MG2AuthRouter.refresh(refreshToken: refreshToken))
        return response.result.toDomain()
    }

    func logout() async throws {
        try await networkProvider.requestEmpty(target: MG2AuthRouter.logout)
    }

    func withdraw() async throws {
        try await networkProvider.requestEmpty(target: MG2AuthRouter.withdraw)
    }
}
