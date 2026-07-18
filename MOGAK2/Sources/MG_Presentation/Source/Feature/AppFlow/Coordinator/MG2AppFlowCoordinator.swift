import UIKit

final class MG2AppFlowCoordinator: MG2PresentationCoordinator {
    var onRouteChange: ((MG2AppLaunchRoute) -> Void)?

    private let viewModel: MG2AppLaunchViewModel
    private let loginCoordinator: MG2LoginCoordinator
    private let tabBarCoordinator: MG2TabBarCoordinator
    private let onboardingCoordinator: MG2OnboardingCoordinator

    init(
        viewModel: MG2AppLaunchViewModel,
        loginCoordinator: MG2LoginCoordinator,
        tabBarCoordinator: MG2TabBarCoordinator,
        onboardingCoordinator: MG2OnboardingCoordinator
    ) {
        self.viewModel = viewModel
        self.loginCoordinator = loginCoordinator
        self.tabBarCoordinator = tabBarCoordinator
        self.onboardingCoordinator = onboardingCoordinator
    }

    func start() -> UIViewController {
        return makeRoot(for: viewModel.resolveCurrentRoute())
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
            return onboardingCoordinator.makeContainer { [weak self] in
                guard let self else { return }
                viewModel.completeOnboarding()
                onRouteChange?(.login)
            }
        }
    }
}
