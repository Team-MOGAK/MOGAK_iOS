import UIKit

@MainActor
final class MG2ScheduleStartCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        ScheduleStartViewController()
    }
}
