import UIKit

@MainActor
final class MG2ScheduleListCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        ScheduleListViewController()
    }
}
