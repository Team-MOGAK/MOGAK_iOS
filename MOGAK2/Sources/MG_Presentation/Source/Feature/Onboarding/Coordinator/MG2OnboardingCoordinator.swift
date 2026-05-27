import UIKit

@MainActor
final class MG2OnboardingCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        MG2OnboardingContainerViewController(viewModel: MG2OnboardingViewModel())
    }
}
