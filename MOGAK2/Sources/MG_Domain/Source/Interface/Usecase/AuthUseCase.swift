import Foundation

protocol AuthUseCase {
    func login(idToken: String) async throws -> MG2AuthSession
    func refresh(refreshToken: String) async throws -> MG2TokenPair
    func logout(accessToken: String?) async throws
    func withdraw(accessToken: String?) async throws -> Bool
    func revokeAppleToken(refreshToken: String) async throws
}
