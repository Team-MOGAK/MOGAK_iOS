import UIKit
final class MG2OnboardingCoordinator: MG2PresentationCoordinator {
    private let viewModel: MG2OnboardingViewModel

    init(viewModel: MG2OnboardingViewModel) {
        self.viewModel = viewModel
    }

    func start() -> UIViewController {
        makeContainer()
    }

    func makeContainer(onFinish: (() -> Void)? = nil) -> UIViewController {
        let pages = [
            MG2OnBoardingFirstViewController(),
            MG2OnBoardingSecondViewController(),
            MG2OnBoardingThirdViewController(),
            MG2OnBoardingForthViewController()
        ]
        let viewController = MG2OnboardingContainerViewController(
            viewModel: viewModel,
            pages: pages
        )
        viewController.onFinish = onFinish
        return viewController
    }
}
