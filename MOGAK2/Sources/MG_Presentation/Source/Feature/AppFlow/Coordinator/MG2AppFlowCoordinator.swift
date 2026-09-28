import UIKit

enum MG2AppLaunchRoute: Equatable {
    case login
    case terms
    case main
    case onboarding
}

/// 앱의 첫 화면을 정하고, 로그인 상태에 맞는 루트 화면을 만든다.
@MainActor
final class MG2AppFlowCoordinator {
    var onRouteChange: ((MG2AppLaunchRoute) -> Void)?

    private let authUseCase: AuthUseCase
    private let userState: MG2UserState
    private let loginCoordinator: MG2LoginCoordinator
    private let tabBarCoordinator: MG2TabBarCoordinator
    private let onboardingCoordinator: MG2OnboardingCoordinator

    init(authUseCase: AuthUseCase, userState: MG2UserState, loginCoordinator: MG2LoginCoordinator, tabBarCoordinator: MG2TabBarCoordinator, onboardingCoordinator: MG2OnboardingCoordinator) {
        self.authUseCase = authUseCase
        self.userState = userState
        self.loginCoordinator = loginCoordinator
        self.tabBarCoordinator = tabBarCoordinator
        self.onboardingCoordinator = onboardingCoordinator
    }

    /// 저장된 세션을 되살린 뒤 첫 화면을 정한다.
    func resolveInitialRoute() async -> MG2AppLaunchRoute {
        await authUseCase.restoreSession()
        return resolveRoute(loginState: userState.loginState)
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
