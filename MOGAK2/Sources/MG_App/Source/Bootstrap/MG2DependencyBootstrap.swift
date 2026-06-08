import Foundation
import Alamofire

enum MG2DependencyBootstrap {
    static func registerDefault(container: DIContainer = .shared) {
        registerNetwork(container: container)
        registerScheduleStart(container: container)
        registerAuth(container: container)
        registerModalart(container: container)
        registerNetworking(container: container)
        registerHistory(container: container)
        registerUser(container: container)
        registerViewModels(container: container)
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

    private static func registerNetworking(container: DIContainer) {
        container.register(NetworkingRepository.self) { resolver in
            let networkProvider = resolver.resolve(NetworkProvider.self) ?? DefaultNetworkProvider(session: .default)
            return DefaultNetworkingRepository(networkProvider: networkProvider)
        }

        container.register(NetworkingUseCase.self) { resolver in
            let repository = resolver.resolve(NetworkingRepository.self)
                ?? DefaultNetworkingRepository(networkProvider: DefaultNetworkProvider(session: .default))
            return DefaultNetworkingUseCase(repository: repository)
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

    private static func registerViewModels(container: DIContainer) {
        container.registerMainActor(MG2OnboardingViewModel.self) { _ in
            MG2OnboardingViewModel()
        }

        container.registerMainActor(MG2MainTabBarViewModel.self) { _ in
            MG2MainTabBarViewModel()
        }

        container.registerMainActor(MG2NetworkingViewModel.self) { resolver in
            MG2NetworkingViewModel(useCase: resolver.resolveRequired(NetworkingUseCase.self))
        }

        container.registerMainActor(MG2AppLaunchViewModel.self) { resolver in
            MG2AppLaunchViewModel(authUseCase: resolver.resolveRequired(AuthUseCase.self))
        }

        container.registerMainActor(MG2ScheduleStartViewModel.self) { resolver in
            MG2ScheduleStartViewModel(useCase: resolver.resolveRequired(ScheduleStartUseCase.self))
        }

        container.registerMainActor(MG2AppScheduleStartViewModel.self) { resolver in
            MG2AppScheduleStartViewModel(useCase: resolver.resolveRequired(ScheduleStartUseCase.self))
        }

        container.registerMainActor(MG2ModalartViewModel.self) { resolver in
            MG2ModalartViewModel(useCase: resolver.resolveRequired(ModalartUseCase.self))
        }

        container.registerMainActor(MG2MyHistoryViewModel.self) { resolver in
            MG2MyHistoryViewModel(useCase: resolver.resolveRequired(ModalartUseCase.self))
        }

        container.registerMainActor(MG2InitEditMogakJogakViewModel.self) { resolver in
            MG2InitEditMogakJogakViewModel(useCase: resolver.resolveRequired(HistoryUseCase.self))
        }

        container.registerMainActor(MG2ProfileSetupViewModel.self) { resolver in
            MG2ProfileSetupViewModel(userUseCase: resolver.resolveRequired(UserUseCase.self))
        }

        container.registerMainActor(MG2MyPageViewModel.self) { resolver in
            MG2MyPageViewModel(
                userUseCase: resolver.resolveRequired(UserUseCase.self),
                authUseCase: resolver.resolveRequired(AuthUseCase.self)
            )
        }

        container.registerMainActor(MG2SocialLoginUseCase.self) { resolver in
            DefaultMG2SocialLoginUseCase(authUseCase: resolver.resolveRequired(AuthUseCase.self))
        }

        container.registerMainActor(MG2LoginViewModel.self) { resolver in
            MG2LoginViewModel(useCase: resolver.resolveRequired(MG2SocialLoginUseCase.self))
        }
    }
}
