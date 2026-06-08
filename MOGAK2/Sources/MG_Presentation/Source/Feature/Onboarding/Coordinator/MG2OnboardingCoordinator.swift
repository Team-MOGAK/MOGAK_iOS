import UIKit
final class MG2OnboardingCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        MG2OnboardingContainerViewController(
            viewModel: DIContainer.shared.resolveRequired(MG2OnboardingViewModel.self)
        )
    }
}
