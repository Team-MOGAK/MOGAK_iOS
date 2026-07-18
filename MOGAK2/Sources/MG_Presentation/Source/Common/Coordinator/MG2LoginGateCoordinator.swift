import UIKit

@MainActor
final class MG2LoginGateCoordinator {
    private let loginCoordinator: MG2LoginCoordinator

    init(loginCoordinator: MG2LoginCoordinator) {
        self.loginCoordinator = loginCoordinator
    }

    func present(from source: UIViewController) {
        let alert = UIAlertController(
            title: "로그인 필요",
            message: "해당 기능을 사용하시려면 로그인이 필요합니다. \n로그인 화면으로 이동하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "아니요", style: .cancel))
        alert.addAction(UIAlertAction(title: "네", style: .default) { [weak self, weak source] _ in
            guard let self, let source else { return }
            let loginViewController = loginCoordinator.makeLogin()
            loginViewController.onAuthenticationCompleted = { [weak loginViewController] in
                loginViewController?.dismiss(animated: true)
            }
            loginViewController.onGuestContinue = { [weak loginViewController] in
                loginViewController?.dismiss(animated: true)
            }
            loginViewController.modalPresentationStyle = .overFullScreen
            source.present(loginViewController, animated: false)
        })
        source.present(alert, animated: false)
    }
}
