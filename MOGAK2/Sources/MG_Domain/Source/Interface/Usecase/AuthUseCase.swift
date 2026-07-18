import Foundation

protocol AuthUseCase {
    func login(provider: MG2SocialLoginProvider, token: String) async throws -> MG2AuthSession
    func refresh(refreshToken: String) async throws -> MG2TokenPair
    func logout() async throws
    func withdraw() async throws -> Bool
}
