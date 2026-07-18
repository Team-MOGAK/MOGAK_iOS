import UIKit

final class MG2TabBarCoordinator: MG2PresentationCoordinator {
    private let viewModel: MG2MainTabBarViewModel
    private let scheduleStartCoordinator: MG2ScheduleStartCoordinator
    private let modalartCoordinator: MG2ModalartCoordinator
    private let myPageCoordinator: MG2MyPageCoordinator

    init(
        viewModel: MG2MainTabBarViewModel,
        scheduleStartCoordinator: MG2ScheduleStartCoordinator,
        modalartCoordinator: MG2ModalartCoordinator,
        myPageCoordinator: MG2MyPageCoordinator
    ) {
        self.viewModel = viewModel
        self.scheduleStartCoordinator = scheduleStartCoordinator
        self.modalartCoordinator = modalartCoordinator
        self.myPageCoordinator = myPageCoordinator
    }

    func start() -> UIViewController {
        let navigationControllers = [
            scheduleStartCoordinator.start(),
            modalartCoordinator.start(),
            myPageCoordinator.start()
        ].map(UINavigationController.init(rootViewController:))

        return MG2MainTabBarController(
            viewModel: viewModel,
            navigationControllers: navigationControllers
        )
    }
}
