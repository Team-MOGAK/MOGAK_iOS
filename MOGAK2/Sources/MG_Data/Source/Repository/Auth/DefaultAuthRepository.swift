import Foundation

final class DefaultAuthRepository: AuthRepository {

    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func login(idToken: String) async throws -> MG2AuthSession {
        try await login(provider: .apple, token: idToken)
    }

    func login(provider: MG2SocialLoginProvider, token: String) async throws -> MG2AuthSession {
        let response: MG2AuthLoginResponseDTO = try await networkProvider.request(
            target: AuthRouter.socialLogin(provider: provider.rawValue, token: token)
        )
        guard let session = response.result?.toDomain() else {
            throw NSError(domain: "AuthRepository", code: -1)
        }
        return session
    }

    func refresh(refreshToken: String) async throws -> MG2TokenPair {
        let response: MG2RefreshResponseDTO = try await networkProvider.request(target: AuthRouter.refresh(refreshToken: refreshToken))
        guard let token = response.result?.toDomain() else {
            throw NSError(domain: "AuthRepository", code: -2)
        }
        return token
    }

    func logout(accessToken: String?) async throws {
        try await networkProvider.requestEmpty(target: AuthRouter.logout(accessToken: accessToken))
    }

    func withdraw(accessToken: String?) async throws -> Bool {
        let response: MG2WithdrawResponseDTO = try await networkProvider.request(target: AuthRouter.withdraw(accessToken: accessToken))
        return response.result.deleted
    }

    func revokeAppleToken(refreshToken: String) async throws {
        let encoded = "https://us-central1-pickdrink-492de.cloudfunctions.net/revokeToken?refresh_token=\(refreshToken)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://apple.com"

        guard let url = URL(string: encoded) else {
            throw NSError(domain: "AuthRepository", code: -3)
        }

        let (_, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<500).contains(httpResponse.statusCode) else {
            throw NSError(domain: "AuthRepository", code: -4)
        }
    }
}
