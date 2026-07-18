import Foundation

@MainActor
protocol MG2SocialLoginUseCase {
    func login(provider: MG2SocialLoginProvider) async throws -> MG2AuthSession
}
