import UIKit

final class MG2LoginCoordinator: MG2PresentationCoordinator {
    private let loginViewModel: MG2LoginViewModel
    private let profileViewModel: MG2ProfileSetupViewModel
    private let alertCoordinator = MG2AlertCoordinator()

    init(
        loginViewModel: MG2LoginViewModel,
        profileViewModel: MG2ProfileSetupViewModel
    ) {
        self.loginViewModel = loginViewModel
        self.profileViewModel = profileViewModel
    }

    func start() -> UIViewController {
        makeLogin()
    }

    func makeLogin() -> MG2LoginViewController {
        let viewController = MG2LoginViewController(viewModel: loginViewModel)
        viewController.coordinator = self
        return viewController
    }

    func makeTerms() -> UIViewController {
        profileViewModel.resetAgreements()
        let vc = MG2TermsAgreeViewController(profileViewModel: profileViewModel)
        vc.coordinator = self
        return vc
    }

    func makeNickname(mode: MG2ProfileSetupMode = .registration) -> UIViewController {
        profileViewModel.beginNicknameSetup()
        let vc = MG2NicknameViewController(mode: mode, profileViewModel: profileViewModel)
        vc.coordinator = self
        return vc
    }

    func makeChooseJob(mode: MG2ProfileSetupMode = .registration) -> UIViewController {
        profileViewModel.beginJobSelection()
        let vc = MG2ChooseJobViewController(mode: mode, profileViewModel: profileViewModel)
        vc.coordinator = self
        return vc
    }

    func makeChooseRegion() -> UIViewController {
        profileViewModel.beginRegionSelection()
        let viewController = MG2ChooseRegionViewController(profileViewModel: profileViewModel)
        viewController.coordinator = self
        return viewController
    }

    func routeToNickname(from source: UIViewController) {
        source.navigationController?.pushViewController(makeNickname(), animated: true)
    }

    func routeToChooseJob(from source: UIViewController) {
        source.navigationController?.pushViewController(makeChooseJob(), animated: true)
    }

    func routeToChooseRegion(from source: UIViewController) {
        source.navigationController?.pushViewController(makeChooseRegion(), animated: true)
    }

    func routeToTerms(from source: UIViewController) {
        routeToWeb(destination: .terms, from: source)
    }

    func routeToPrivacy(from source: UIViewController) {
        routeToWeb(destination: .privacy, from: source)
    }

    func routeBack(from source: UIViewController) {
        source.navigationController?.popViewController(animated: true)
    }

    private func routeToWeb(destination: MG2WebDestination, from source: UIViewController) {
        source.navigationController?.pushViewController(
            MG2WebViewController(destination: destination),
            animated: true
        )
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    func presentLoginError(
        _ message: String,
        from source: UIViewController,
        onDismiss: @escaping () -> Void
    ) {
        alertCoordinator.presentInfo(
            title: "로그인 실패",
            message: message,
            from: source,
            onDismiss: onDismiss
        )
    }

}
