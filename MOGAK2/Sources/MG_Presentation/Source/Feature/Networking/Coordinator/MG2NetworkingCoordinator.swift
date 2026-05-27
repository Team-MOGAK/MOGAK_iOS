import UIKit

@MainActor
final class MG2NetworkingCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        NetworkingViewController()
    }
}
