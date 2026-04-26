import UIKit

final class MG2AppFlowCoordinator: MG2PresentationCoordinator {

    private let viewModel = MG2AppLaunchViewModel()
    private let loginCoordinator = MG2LoginCoordinator()
    private let tabBarCoordinator = MG2TabBarCoordinator()
    private let onboardingCoordinator = MG2OnboardingCoordinator()

    func start() -> UIViewController {
        return makeRoot(for: viewModel.resolveRoute(loginState: MG2Deps.app.userState.loginState))
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
            guard let onboarding = onboardingCoordinator.start() as? MG2OnboardingContainerViewController else {
                return onboardingCoordinator.start()
            }
            onboarding.onFinish = { [weak self] in
                guard let self else { return }
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows.first?.rootViewController = self.makeRoot(for: .login)
            }
            return onboarding
        }
    }
}
