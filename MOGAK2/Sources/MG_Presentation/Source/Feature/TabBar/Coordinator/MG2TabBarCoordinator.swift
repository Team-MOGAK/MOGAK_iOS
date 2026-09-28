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
        let tabs = [
            (scheduleStartCoordinator.start(), "조각시작", "start", "selectedStart"),
            (modalartCoordinator.start(), "모다라트", "modalArt", "selectedModalArt"),
            (myPageCoordinator.start(), "마이페이지", "mypage", "selectedMypage")
        ]
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = tabs.map { root, title, imageName, selectedImageName in
            let navigationController = UINavigationController(rootViewController: root)
            navigationController.tabBarItem = UITabBarItem(title: title, image: UIImage(named: imageName), selectedImage: UIImage(named: selectedImageName))
            return navigationController
        }
        return tabBarController
    }
}
