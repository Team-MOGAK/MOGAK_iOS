import UIKit

final class MG2MyPageCoordinator: MG2PresentationCoordinator {
    private let viewModel: MG2MyPageViewModel
    private let loginCoordinator: MG2LoginCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let alertCoordinator = MG2AlertCoordinator()

    init(viewModel: MG2MyPageViewModel, loginCoordinator: MG2LoginCoordinator) {
        self.viewModel = viewModel
        self.loginCoordinator = loginCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let vc = MG2MyPageViewController(viewModel: viewModel)
        vc.coordinator = self
        return vc
    }

    func makeEditViewController() -> UIViewController {
        let vc = MG2MyPageEditViewController(viewModel: viewModel)
        vc.coordinator = self
        return vc
    }

    func makeWebViewController(destination: MG2WebDestination) -> UIViewController {
        MG2WebViewController(destination: destination)
    }

    func routeToEdit(from source: UIViewController) {
        source.navigationController?.pushViewController(makeEditViewController(), animated: true)
    }

    func routeToWeb(destination: MG2WebDestination, from source: UIViewController) {
        source.navigationController?.pushViewController(
            makeWebViewController(destination: destination),
            animated: true
        )
    }

    func routeToNicknameEdit(from source: UIViewController) {
        source.navigationController?.pushViewController(
            loginCoordinator.makeNickname(mode: .editing),
            animated: true
        )
    }

    func routeToJobEdit(from source: UIViewController) {
        source.navigationController?.pushViewController(
            loginCoordinator.makeChooseJob(mode: .editing),
            animated: true
        )
    }

    func presentLoginGate(from source: UIViewController) {
        loginGateCoordinator.present(from: source)
    }

    func presentWithdrawalConfirmation(
        onConfirm: @escaping () -> Void,
        from source: UIViewController
    ) {
        let alert = UIAlertController(
            title: "정말 회원탈퇴를 하시겠습니까?",
            message: "회원탈퇴를 하시면 데이터를 복원할 수 없습니다!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { _ in
            onConfirm()
        })
        source.present(alert, animated: true)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    func presentUnavailableFeature(_ message: String, from source: UIViewController) {
        alertCoordinator.presentInfo(title: "준비중", message: message, from: source)
    }
}
