import UIKit

@MainActor
final class MG2OnboardingCoordinator {
    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func start(onFinish: @escaping () -> Void) -> UIViewController {
        let viewController = MG2OnboardingViewController(viewModel: MG2OnboardingViewModel(authUseCase: authUseCase))
        viewController.onFinish = onFinish
        return viewController
    }
}
