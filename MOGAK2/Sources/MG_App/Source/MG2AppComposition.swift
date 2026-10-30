import Combine
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
    private lazy var serverHealthRepository: ServerHealthRepository = DefaultServerHealthRepository(networkProvider: networkProvider)
    private lazy var userRepository: UserRepository = DefaultUserRepository(networkProvider: networkProvider, loadProfileImageID: { [sessionStore] in sessionStore.profileImageID }, saveProfileImageID: { [sessionStore] in sessionStore.saveProfileImageID($0) })

    private lazy var authUseCase = AuthUseCase(repository: authRepository, storage: sessionStore, socialTokenProvider: MG2SocialTokenProvider(), userState: userState)
    private lazy var serverReadinessUseCase = ServerReadinessUseCase(repository: serverHealthRepository)
    private lazy var userUseCase = UserUseCase(repository: userRepository, storage: sessionStore, userState: userState)
    private lazy var modalartUseCase = ModalartUseCase(repository: modalartRepository, jogakRepository: scheduleStartRepository)
    private lazy var mogakEditingUseCase = MogakEditingUseCase(repository: mogakEditingRepository)
    private lazy var scheduleStartUseCase = ScheduleStartUseCase(repository: scheduleStartRepository, modalartRepository: modalartRepository)
    private lazy var todayUseCase = TodayUseCase(repository: scheduleStartRepository, snapshotStorage: MG2TodaySnapshotStore(), surfaces: MG2TodaySurfaceRefresher(), reminder: MG2ReminderScheduler())

    /// 광고 노출 규칙과 AdMob 어댑터. SceneDelegate가 앱 열기 광고에 같이 쓴다.
    lazy var adPolicyUseCase = AdPolicyUseCase(storage: MG2AdPolicyStore())
    let adProvider = MG2AdMobProvider()
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    /// 위젯 · 라이브 액티비티 버튼(LiveActivityIntent)이 앱 프로세스에서 오늘 조각을 바꾸게 연결한다.
    /// 메인 화면에 들어오면 필요한 권한을 차례로 받는다: 알림 → 광고 추적(ATT) · 동의(UMP).
    /// 시스템 권한 창이 닫히면 앱이 다시 활성화되므로 여러 번 불려도 각 권한은 한 번만 묻는다.
    func requestStartupPermissions() async {
        await todayUseCase.requestReminderPermissionIfNeeded()
        // TODO(ads): 광고 SDK 시작 (추적 허용 · 동의 창도 이때 뜬다).
        // 되살릴 때 Info.plist에 NSUserTrackingUsageDescription(추적 허용 문구)을 꼭 넣는다. 없으면 추적 허용 창을 띄우는 순간 앱이 종료된다.
        // GADApplicationIdentifier · 광고 단위 ID도 테스트 값이라 실제 값으로 바꾼다.
        // adProvider.start()
    }

    func connectPieceIntents() {
        MG2PieceIntentBridge.completeNext = { [todayUseCase] in try await todayUseCase.completeNextPiece() }
        MG2PieceIntentBridge.toggle = { [todayUseCase] in try await todayUseCase.togglePiece(jogakID: $0) }
        // 로그아웃 · 탈퇴 · 둘러보기로 바뀌면 앞 계정 조각을 위젯 · 라이브 액티비티에서 지운다.
        userState.$loginState
            .removeDuplicates()
            .filter { $0 == .logout || $0 == .guest }
            .sink { [todayUseCase] _ in todayUseCase.clearSurfaces() }
            .store(in: &cancellables)
    }

    /// 첫 화면을 정하고 루트 화면을 만드는 Coordinator. 앱 실행마다 한 번 만든다.
    func makeAppFlowCoordinator() -> MG2AppFlowCoordinator {
        let loginCoordinator = MG2LoginCoordinator(authUseCase: authUseCase, userUseCase: userUseCase, userState: userState)
        let formCoordinator = MG2MogakJogakFormCoordinator(useCase: mogakEditingUseCase)
        let scheduleStartCoordinator = MG2ScheduleStartCoordinator(useCase: scheduleStartUseCase, todayUseCase: todayUseCase, adPolicyUseCase: adPolicyUseCase, adProvider: adProvider, userState: userState, formCoordinator: formCoordinator, loginCoordinator: loginCoordinator)
        let modalartCoordinator = MG2ModalartCoordinator(useCase: modalartUseCase, adPolicyUseCase: adPolicyUseCase, adProvider: adProvider, userState: userState, formCoordinator: formCoordinator, loginCoordinator: loginCoordinator)
        let myPageCoordinator = MG2MyPageCoordinator(userUseCase: userUseCase, authUseCase: authUseCase, userState: userState, loginCoordinator: loginCoordinator, todayUseCase: todayUseCase, adPolicyUseCase: adPolicyUseCase, adProvider: adProvider)
        let tabBarCoordinator = MG2TabBarCoordinator(scheduleStartCoordinator: scheduleStartCoordinator, modalartCoordinator: modalartCoordinator, myPageCoordinator: myPageCoordinator)
        let onboardingCoordinator = MG2OnboardingCoordinator(authUseCase: authUseCase)

        return MG2AppFlowCoordinator(authUseCase: authUseCase, serverReadinessUseCase: serverReadinessUseCase, userState: userState, loginCoordinator: loginCoordinator, tabBarCoordinator: tabBarCoordinator, onboardingCoordinator: onboardingCoordinator)
    }
}
