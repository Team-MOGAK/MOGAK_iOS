import Foundation

enum MG2DependencyBootstrap {
    static func registerDefault(
        container: DIContainer = .shared,
        appDependencies: MG2AppDependencies
    ) {
        container.register(MG2AppDependencies.self) { _ in appDependencies }
        registerNetwork(container: container, appDependencies: appDependencies)
        registerScheduleStart(container: container)
        registerAuth(container: container)
        registerModalart(container: container)
        registerMogakEditing(container: container)
        registerUser(container: container)
        registerViewModels(container: container, appDependencies: appDependencies)
    }

    private static func registerNetwork(
        container: DIContainer,
        appDependencies: MG2AppDependencies
    ) {
        container.register(NetworkProvider.self) { _ in
            DefaultNetworkProvider {
                appDependencies.sessionStore.accessToken
            }
        }
    }

    private static func registerScheduleStart(container: DIContainer) {
        container.register(ScheduleStartRepository.self) { resolver in
            DefaultScheduleStartRepository(networkProvider: resolver.resolveRequired(NetworkProvider.self))
        }

        container.register(ScheduleStartUseCase.self) { resolver in
            DefaultScheduleStartUseCase(repository: resolver.resolveRequired(ScheduleStartRepository.self))
        }
    }

    private static func registerAuth(container: DIContainer) {
        container.register(AuthRepository.self) { resolver in
            DefaultAuthRepository(networkProvider: resolver.resolveRequired(NetworkProvider.self))
        }

        container.register(AuthUseCase.self) { resolver in
            DefaultAuthUseCase(repository: resolver.resolveRequired(AuthRepository.self))
        }
    }

    private static func registerModalart(container: DIContainer) {
        container.register(ModalartRepository.self) { resolver in
            DefaultModalartRepository(networkProvider: resolver.resolveRequired(NetworkProvider.self))
        }

        container.register(ModalartUseCase.self) { resolver in
            DefaultModalartUseCase(repository: resolver.resolveRequired(ModalartRepository.self))
        }
    }

    private static func registerMogakEditing(container: DIContainer) {
        container.register(MogakEditingRepository.self) { resolver in
            DefaultMogakEditingRepository(networkProvider: resolver.resolveRequired(NetworkProvider.self))
        }

        container.register(MogakEditingUseCase.self) { resolver in
            DefaultMogakEditingUseCase(repository: resolver.resolveRequired(MogakEditingRepository.self))
        }
    }

    private static func registerUser(container: DIContainer) {
        container.register(UserRepository.self) { resolver in
            DefaultUserRepository(networkProvider: resolver.resolveRequired(NetworkProvider.self))
        }

        container.register(UserUseCase.self) { resolver in
            DefaultUserUseCase(repository: resolver.resolveRequired(UserRepository.self))
        }
    }

    private static func registerViewModels(
        container: DIContainer,
        appDependencies: MG2AppDependencies
    ) {
        container.register(MG2OnboardingViewModel.self) { _ in
            MG2OnboardingViewModel()
        }

        container.register(MG2MainTabBarViewModel.self) { _ in
            MG2MainTabBarViewModel()
        }

        container.register(MG2AppLaunchViewModel.self) { resolver in
            MG2AppLaunchViewModel(
                authUseCase: resolver.resolveRequired(AuthUseCase.self),
                userState: appDependencies.userState,
                sessionStore: appDependencies.sessionStore
            )
        }

        container.registerMainActor(MG2ScheduleStartViewModel.self) { resolver in
            MG2ScheduleStartViewModel(
                useCase: resolver.resolveRequired(ScheduleStartUseCase.self),
                userState: appDependencies.userState
            )
        }

        container.registerMainActor(MG2JogakSelectionViewModel.self) { resolver in
            MG2JogakSelectionViewModel(
                modalartUseCase: resolver.resolveRequired(ModalartUseCase.self),
                scheduleUseCase: resolver.resolveRequired(ScheduleStartUseCase.self)
            )
        }

        container.registerMainActor(MG2ModalartViewModel.self) { resolver in
            MG2ModalartViewModel(
                useCase: resolver.resolveRequired(ModalartUseCase.self),
                userState: appDependencies.userState
            )
        }

        container.registerMainActor(MG2MogakFormViewModel.self) { resolver in
            MG2MogakFormViewModel(useCase: resolver.resolveRequired(MogakEditingUseCase.self))
        }

        container.registerMainActor(MG2JogakFormViewModel.self) { resolver in
            MG2JogakFormViewModel(useCase: resolver.resolveRequired(MogakEditingUseCase.self))
        }

        container.registerMainActor(MG2ProfileSetupViewModel.self) { resolver in
            MG2ProfileSetupViewModel(
                userUseCase: resolver.resolveRequired(UserUseCase.self),
                userState: appDependencies.userState,
                sessionStore: appDependencies.sessionStore
            )
        }

        container.registerMainActor(MG2MyPageViewModel.self) { resolver in
            MG2MyPageViewModel(
                userUseCase: resolver.resolveRequired(UserUseCase.self),
                authUseCase: resolver.resolveRequired(AuthUseCase.self),
                userState: appDependencies.userState,
                sessionStore: appDependencies.sessionStore
            )
        }

        container.registerMainActor(MG2SocialLoginUseCase.self) { resolver in
            DefaultMG2SocialLoginUseCase(
                authUseCase: resolver.resolveRequired(AuthUseCase.self),
                appleTokenProvider: MG2AppleLoginManager(),
                googleTokenProvider: MG2GoogleLoginManager(),
                kakaoTokenProvider: MG2KakaoLoginManager()
            )
        }

        container.registerMainActor(MG2LoginViewModel.self) { resolver in
            MG2LoginViewModel(
                useCase: resolver.resolveRequired(MG2SocialLoginUseCase.self),
                userState: appDependencies.userState,
                sessionStore: appDependencies.sessionStore
            )
        }
    }
}
