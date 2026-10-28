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
        MG2MainTabViewController(scheduleStart: scheduleStartCoordinator.start(), modalart: modalartCoordinator.start(), myPage: myPageCoordinator.start())
    }
}
