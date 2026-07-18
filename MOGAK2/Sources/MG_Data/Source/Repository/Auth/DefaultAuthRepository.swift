import Foundation

final class DefaultAuthRepository: AuthRepository {

    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func login(provider: MG2SocialLoginProvider, token: String) async throws -> MG2AuthSession {
        let response: MG2AuthLoginResponseDTO = try await networkProvider.request(
            target: AuthRouter.socialLogin(provider: provider.rawValue, token: token)
        )
        return response.result.toDomain()
    }

    func refresh(refreshToken: String) async throws -> MG2TokenPair {
        let response: MG2RefreshResponseDTO = try await networkProvider.request(target: AuthRouter.refresh(refreshToken: refreshToken))
        return response.result.toDomain()
    }

    func logout() async throws {
        try await networkProvider.requestEmpty(target: AuthRouter.logout)
    }

    func withdraw() async throws -> Bool {
        let response: MG2WithdrawResponseDTO = try await networkProvider.request(target: AuthRouter.withdraw)
        return response.result.isDeleted
    }

}
