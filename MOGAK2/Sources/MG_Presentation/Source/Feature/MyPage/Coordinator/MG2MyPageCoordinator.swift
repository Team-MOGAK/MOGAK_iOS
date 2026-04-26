import UIKit

final class MG2MyPageCoordinator: MG2PresentationCoordinator {
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

    func routeToEdit(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeEditViewController(), animated: true)
    }

    func routeToWeb(url: MG2WebUrl, from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeWebViewController(url: url), animated: true)
    }

    func routeToNicknameEdit(from navigationController: UINavigationController?) {
        let vc = MG2NicknameViewController()
        vc.nicknameAndImageChange = true
        vc.coordinator = MG2LoginCoordinator()
        navigationController?.pushViewController(vc, animated: true)
    }

    func routeToJobEdit(from navigationController: UINavigationController?) {
        let vc = MG2ChooseJobViewController()
        vc.changeJob = true
        vc.coordinator = MG2LoginCoordinator()
        navigationController?.pushViewController(vc, animated: true)
    }
}
