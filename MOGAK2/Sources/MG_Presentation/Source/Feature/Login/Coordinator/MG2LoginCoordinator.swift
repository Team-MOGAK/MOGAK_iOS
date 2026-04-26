import UIKit

final class MG2LoginCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        let vc = MG2LoginViewController()
        vc.coordinator = self
        return vc
    }

    func makeTerms() -> UIViewController {
        let vc = MG2TermsAgreeViewController()
        vc.coordinator = self
        return vc
    }

    func makeNickname() -> UIViewController {
        let vc = MG2NicknameViewController()
        vc.coordinator = self
        return vc
    }

    func makeChooseJob(changeJob: Bool = false) -> UIViewController {
        let vc = MG2ChooseJobViewController()
        vc.coordinator = self
        vc.changeJob = changeJob
        return vc
    }

    func makeChooseRegion() -> UIViewController {
        let vc = MG2ChooseRegionViewController()
        vc.coordinator = self
        return vc
    }

    func routeToTerms(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeTerms(), animated: true)
    }

    func routeToNickname(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeNickname(), animated: true)
    }

    func routeToChooseJob(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeChooseJob(), animated: true)
    }

    func routeToChooseRegion(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeChooseRegion(), animated: true)
    }

    func routeToMain(window: UIWindow?) {
        let tabBarController = MG2MainTabBarController(viewModel: MG2MainTabBarViewModel())
        window?.rootViewController = tabBarController
    }
}
