import Foundation
import Alamofire

enum MG2DependencyBootstrap {
    static func registerDefault(container: DIContainer = .shared) {
        registerNetwork(container: container)
        registerScheduleStart(container: container)
        registerAuth(container: container)
        registerModalart(container: container)
        registerHistory(container: container)
        registerUser(container: container)
    }

    private static func registerNetwork(container: DIContainer) {
        container.register(NetworkProvider.self) { _ in
            DefaultNetworkProvider(session: .default)
        }
    }

    private static func registerScheduleStart(container: DIContainer) {
        container.register(ScheduleStartRepository.self) { resolver in
            let networkProvider = resolver.resolve(NetworkProvider.self) ?? DefaultNetworkProvider(session: .default)
            return DefaultScheduleStartRepository(networkProvider: networkProvider)
        }

        container.register(ScheduleStartUseCase.self) { resolver in
            let repository = resolver.resolve(ScheduleStartRepository.self)
                ?? DefaultScheduleStartRepository(networkProvider: DefaultNetworkProvider(session: .default))
            return DefaultScheduleStartUseCase(repository: repository)
        }
    }

    private static func registerAuth(container: DIContainer) {
        container.register(AuthRepository.self) { resolver in
            let networkProvider = resolver.resolve(NetworkProvider.self) ?? DefaultNetworkProvider(session: .default)
            return DefaultAuthRepository(networkProvider: networkProvider)
        }

        container.register(AuthUseCase.self) { resolver in
            let repository = resolver.resolve(AuthRepository.self)
                ?? DefaultAuthRepository(networkProvider: DefaultNetworkProvider(session: .default))
            return DefaultAuthUseCase(repository: repository)
        }
    }

    private static func registerModalart(container: DIContainer) {
        container.register(ModalartRepository.self) { resolver in
            let networkProvider = resolver.resolve(NetworkProvider.self) ?? DefaultNetworkProvider(session: .default)
            return DefaultModalartRepository(networkProvider: networkProvider)
        }

        container.register(ModalartUseCase.self) { resolver in
            let repository = resolver.resolve(ModalartRepository.self)
                ?? DefaultModalartRepository(networkProvider: DefaultNetworkProvider(session: .default))
            return DefaultModalartUseCase(repository: repository)
        }
    }

    private static func registerHistory(container: DIContainer) {
        container.register(HistoryRepository.self) { resolver in
            let networkProvider = resolver.resolve(NetworkProvider.self) ?? DefaultNetworkProvider(session: .default)
            return DefaultHistoryRepository(networkProvider: networkProvider)
        }

        container.register(HistoryUseCase.self) { resolver in
            let repository = resolver.resolve(HistoryRepository.self)
                ?? DefaultHistoryRepository(networkProvider: DefaultNetworkProvider(session: .default))
            return DefaultHistoryUseCase(repository: repository)
        }
    }

    private static func registerUser(container: DIContainer) {
        container.register(UserRepository.self) { resolver in
            let networkProvider = resolver.resolve(NetworkProvider.self) ?? DefaultNetworkProvider(session: .default)
            return DefaultUserRepository(networkProvider: networkProvider)
        }

        container.register(UserUseCase.self) { resolver in
            let repository = resolver.resolve(UserRepository.self)
                ?? DefaultUserRepository(networkProvider: DefaultNetworkProvider(session: .default))
            return DefaultUserUseCase(repository: repository)
        }
    }
}
