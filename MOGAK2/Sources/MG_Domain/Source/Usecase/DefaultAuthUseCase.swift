import Foundation

final class DefaultAuthUseCase: AuthUseCase {

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func login(idToken: String) async throws -> MG2AuthSession {
        try await login(provider: .apple, token: idToken)
    }

    func login(provider: MG2SocialLoginProvider, token: String) async throws -> MG2AuthSession {
        try await repository.login(provider: provider, token: token)
    }

    func refresh(refreshToken: String) async throws -> MG2TokenPair {
        try await repository.refresh(refreshToken: refreshToken)
    }

    func logout(accessToken: String?) async throws {
        try await repository.logout(accessToken: accessToken)
    }

    func withdraw(accessToken: String?) async throws -> Bool {
        try await repository.withdraw(accessToken: accessToken)
    }

    func revokeAppleToken(refreshToken: String) async throws {
        try await repository.revokeAppleToken(refreshToken: refreshToken)
    }
}
