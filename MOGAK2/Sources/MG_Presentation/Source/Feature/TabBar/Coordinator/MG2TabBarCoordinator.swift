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

    /// 첫 탭(홈)에 보일 데이터를 미리 불러 둔다.
    func prepare() async {
        await scheduleStartCoordinator.prepare()
    }

    func start() -> UIViewController {
        MG2MainTabViewController(scheduleStart: scheduleStartCoordinator.start(), modalart: modalartCoordinator.start(), myPage: myPageCoordinator.start())
    }
}
