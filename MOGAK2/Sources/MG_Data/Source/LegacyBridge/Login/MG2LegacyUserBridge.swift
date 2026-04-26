import Foundation

final class MG2LegacyUserBridge {

    static let shared = MG2LegacyUserBridge()

    fileprivate let useCase: UserUseCase

    private init() {
        let provider = DefaultNetworkProvider(session: .default)
        let repository = DefaultUserRepository(networkProvider: provider)
        self.useCase = DefaultUserUseCase(repository: repository)
    }
}
