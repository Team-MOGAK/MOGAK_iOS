import UIKit

@MainActor
final class MG2TabBarCoordinator {
    private let scheduleStartCoordinator: MG2ScheduleStartCoordinator
    private let modalartCoordinator: MG2ModalartCoordinator
    private let myPageCoordinator: MG2MyPageCoordinator

    init(scheduleStartCoordinator: MG2ScheduleStartCoordinator, modalartCoordinator: MG2ModalartCoordinator, myPageCoordinator: MG2MyPageCoordinator) {
        self.scheduleStartCoordinator = scheduleStartCoordinator
        self.modalartCoordinator = modalartCoordinator
        self.myPageCoordinator = myPageCoordinator
    }

    func start() -> UIViewController {
        let roots = [scheduleStartCoordinator.start(), modalartCoordinator.start(), myPageCoordinator.start()]
        return MG2MainTabViewController(navigationControllers: roots.map(UINavigationController.init(rootViewController:)))
    }
}
