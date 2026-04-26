import UIKit

final class MG2TabBarCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        MG2MainTabBarController(viewModel: MG2MainTabBarViewModel())
    }
}
