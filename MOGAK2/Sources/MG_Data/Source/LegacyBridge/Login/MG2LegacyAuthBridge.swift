import Foundation

final class MG2LegacyAuthBridge {

    static let shared = MG2LegacyAuthBridge()

    let useCase: AuthUseCase

    private init() {
        let provider = DefaultNetworkProvider(session: .default)
        let repository = DefaultAuthRepository(networkProvider: provider)
        self.useCase = DefaultAuthUseCase(repository: repository)
    }
}
