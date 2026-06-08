import UIKit

final class MG2LoginCoordinator: MG2PresentationCoordinator {
    func start() -> UIViewController {
        let vc = MG2LoginViewController()
        vc.coordinator = self
        return vc
    }

    @MainActor
    func makeTerms() -> UIViewController {
        let vc = MG2TermsAgreeViewController()
        vc.coordinator = self
        return vc
    }

    @MainActor
    func makeNickname() -> UIViewController {
        let vc = MG2NicknameViewController()
        vc.coordinator = self
        return vc
    }

    @MainActor
    func makeChooseJob(changeJob: Bool = false) -> UIViewController {
        let vc = MG2ChooseJobViewController()
        vc.coordinator = self
        vc.changeJob = changeJob
        return vc
    }

    @MainActor
    func makeChooseRegion() -> UIViewController {
        let vc = MG2ChooseRegionViewController()
        vc.coordinator = self
        return vc
    }

    @MainActor
    func routeToTerms(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeTerms(), animated: true)
    }

    @MainActor
    func routeToNickname(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeNickname(), animated: true)
    }

    @MainActor
    func routeToChooseJob(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeChooseJob(), animated: true)
    }

    @MainActor
    func routeToChooseRegion(from navigationController: UINavigationController?) {
        navigationController?.pushViewController(makeChooseRegion(), animated: true)
    }

    @MainActor
    func routeToMain(window: UIWindow?) {
        let tabBarController = MG2TabBarCoordinator().start()
        window?.rootViewController = tabBarController
    }
}
