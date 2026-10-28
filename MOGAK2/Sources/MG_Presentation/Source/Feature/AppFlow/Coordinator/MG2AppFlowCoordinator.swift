import UIKit

enum MG2AppLaunchRoute: Equatable {
    /// 서버가 깨어나길 기다리는 첫 화면
    case launch
    case login
    case terms
    case main
    case onboarding
}

/// 스플래시가 하는 일. 로딩 아래 문구가 단계마다 바뀐다.
enum MG2LaunchStep {
    case connecting, restoringSession, loadingHome

    var message: String {
        switch self {
        case .connecting: return "앱을 준비하고 있어요"
        case .restoringSession: return "로그인 정보를 확인하고 있어요"
        case .loadingHome: return "오늘의 조각을 불러오고 있어요"
        }
    }
}

/// 앱의 첫 화면을 정하고, 로그인 상태에 맞는 루트 화면을 만든다.
@MainActor
final class MG2AppFlowCoordinator {
    var onRouteChange: ((MG2AppLaunchRoute) -> Void)?

    private let authUseCase: AuthUseCase
    private let serverReadinessUseCase: ServerReadinessUseCase
    private let userState: MG2UserState
    private let loginCoordinator: MG2LoginCoordinator
    private let tabBarCoordinator: MG2TabBarCoordinator
    private let onboardingCoordinator: MG2OnboardingCoordinator

    init(authUseCase: AuthUseCase, serverReadinessUseCase: ServerReadinessUseCase, userState: MG2UserState, loginCoordinator: MG2LoginCoordinator, tabBarCoordinator: MG2TabBarCoordinator, onboardingCoordinator: MG2OnboardingCoordinator) {
        self.authUseCase = authUseCase
        self.serverReadinessUseCase = serverReadinessUseCase
        self.userState = userState
        self.loginCoordinator = loginCoordinator
        self.tabBarCoordinator = tabBarCoordinator
        self.onboardingCoordinator = onboardingCoordinator
    }

    /// 서버가 준비된 뒤에 저장된 세션을 되살리고, 첫 화면 데이터까지 준비한 뒤 넘어간다.
    /// 로딩은 스플래시 한 번으로 끝낸다. 단계가 바뀔 때마다 onStep으로 알린다.
    func finishLaunch(onStep: @escaping (MG2LaunchStep) -> Void) {
        Task {
            onStep(.restoringSession)
            await authUseCase.restoreSession()
            let route = resolveRoute(loginState: userState.loginState)
            if route == .main {
                onStep(.loadingHome)
                await tabBarCoordinator.prepare()
            }
            onRouteChange?(route)
        }
    }

    func resolveRoute(loginState: MG2LoginStatus?) -> MG2AppLaunchRoute {
        switch loginState {
        case .login:
            return userState.isRegistered ? .main : .terms
        case .guest:
            return .main
        case .logout, nil:
            return authUseCase.isFirstLaunch ? .onboarding : .login
        }
    }

    func makeRoot(for route: MG2AppLaunchRoute) -> UIViewController {
        switch route {
        case .launch:
            let viewController = MG2LaunchViewController(viewModel: MG2LaunchViewModel(serverReadinessUseCase: serverReadinessUseCase))
            viewController.coordinator = self
            return viewController
        case .login:
            return loginCoordinator.start()
        case .terms:
            return UINavigationController(rootViewController: loginCoordinator.makeTerms())
        case .main:
            return tabBarCoordinator.start()
        case .onboarding:
            return onboardingCoordinator.start { [weak self] in self?.onRouteChange?(.login) }
        }
    }
}
