import UIKit

final class MG2MyPageCoordinator: MG2PresentationCoordinator {
    private let loginCoordinator = MG2LoginCoordinator()

    func start() -> UIViewController {
        let vc = MG2MyPageViewController()
        vc.coordinator = self
        return vc
    }

    func makeEditViewController() -> UIViewController {
        let vc = MG2MyPageEditViewController()
        vc.coordinator = self
        return vc
    }

    func makeWebViewController(url: MG2WebUrl) -> UIViewController {
        let vc = MG2MypageWebViewController()
        vc.url = url
        return vc
    }

    @MainActor
    func routeToEdit(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeEditViewController(), animated: true)
    }

    @MainActor
    func routeToWeb(url: MG2WebUrl, from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeWebViewController(url: url), animated: true)
    }

    @MainActor
    func routeToNicknameEdit(from navigationController: UINavigationController?) {
        let vc = MG2NicknameViewController()
        vc.nicknameAndImageChange = true
        vc.coordinator = loginCoordinator
        navigationController?.pushViewController(vc, animated: true)
    }

    @MainActor
    func routeToJobEdit(from navigationController: UINavigationController?) {
        let vc = MG2ChooseJobViewController()
        vc.changeJob = true
        vc.coordinator = loginCoordinator
        navigationController?.pushViewController(vc, animated: true)
    }
}
