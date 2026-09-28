import Foundation

@MainActor
final class MG2AppComposition {
    static let shared = MG2AppComposition()

    /// 로그인·프로필 상태. UseCase만 바꾸고 화면은 구독한다.
    let userState = MG2UserState()

    private let sessionStore = MG2SessionStore()

    private lazy var networkProvider: NetworkProvider = DefaultNetworkProvider(accessTokenProvider: { [sessionStore] in sessionStore.accessToken }, refreshAccessToken: { [weak self] in try await self?.authUseCase.refreshAccessToken() })

    private lazy var authRepository: AuthRepository = DefaultAuthRepository(networkProvider: networkProvider)
    private lazy var modalartRepository: ModalartRepository = DefaultModalartRepository(networkProvider: networkProvider)
    private lazy var mogakEditingRepository: MogakEditingRepository = DefaultMogakEditingRepository(networkProvider: networkProvider)
    private lazy var scheduleStartRepository: ScheduleStartRepository = DefaultScheduleStartRepository(networkProvider: networkProvider)
    private lazy var userRepository: UserRepository = DefaultUserRepository(networkProvider: networkProvider, loadProfileImageID: { [sessionStore] in sessionStore.profileImageID }, saveProfileImageID: { [sessionStore] in sessionStore.saveProfileImageID($0) })

    private lazy var authUseCase = AuthUseCase(repository: authRepository, storage: sessionStore, socialTokenProvider: MG2SocialTokenProvider(), userState: userState)
    private lazy var userUseCase = UserUseCase(repository: userRepository, storage: sessionStore, userState: userState)
    private lazy var modalartUseCase = ModalartUseCase(repository: modalartRepository, jogakRepository: scheduleStartRepository)
    private lazy var mogakEditingUseCase = MogakEditingUseCase(repository: mogakEditingRepository)
    private lazy var scheduleStartUseCase = ScheduleStartUseCase(repository: scheduleStartRepository, modalartRepository: modalartRepository)

    private init() {}

    /// 첫 화면을 정하고 루트 화면을 만드는 Coordinator. 앱 실행마다 한 번 만든다.
    func makeAppFlowCoordinator() -> MG2AppFlowCoordinator {
        let loginCoordinator = MG2LoginCoordinator(authUseCase: authUseCase, userUseCase: userUseCase, userState: userState)
        let formCoordinator = MG2MogakJogakFormCoordinator(useCase: mogakEditingUseCase)
        let scheduleStartCoordinator = MG2ScheduleStartCoordinator(useCase: scheduleStartUseCase, userState: userState, formCoordinator: formCoordinator, loginCoordinator: loginCoordinator)
        let modalartCoordinator = MG2ModalartCoordinator(useCase: modalartUseCase, userState: userState, formCoordinator: formCoordinator, loginCoordinator: loginCoordinator)
        let myPageCoordinator = MG2MyPageCoordinator(userUseCase: userUseCase, authUseCase: authUseCase, userState: userState, loginCoordinator: loginCoordinator)
        let tabBarCoordinator = MG2TabBarCoordinator(scheduleStartCoordinator: scheduleStartCoordinator, modalartCoordinator: modalartCoordinator, myPageCoordinator: myPageCoordinator)
        let onboardingCoordinator = MG2OnboardingCoordinator(authUseCase: authUseCase)

        return MG2AppFlowCoordinator(authUseCase: authUseCase, userState: userState, loginCoordinator: loginCoordinator, tabBarCoordinator: tabBarCoordinator, onboardingCoordinator: onboardingCoordinator)
    }
}
