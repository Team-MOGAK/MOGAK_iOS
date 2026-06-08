import UIKit

final class MG2TabBarCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        MG2MainTabBarController(
            viewModel: DIContainer.shared.resolveRequired(MG2MainTabBarViewModel.self),
            rootViewControllers: [
                MG2ScheduleStartCoordinator().start(),
                MG2ModalartCoordinator().start(),
                MG2MyPageCoordinator().start()
            ]
        )
    }
}
