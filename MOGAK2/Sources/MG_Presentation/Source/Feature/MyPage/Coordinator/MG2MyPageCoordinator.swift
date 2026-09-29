import UIKit

@MainActor
final class MG2MyPageCoordinator {
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase
    private let userState: MG2UserState
    private let loginCoordinator: MG2LoginCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let alertCoordinator = MG2AlertCoordinator()

    init(userUseCase: UserUseCase, authUseCase: AuthUseCase, userState: MG2UserState, loginCoordinator: MG2LoginCoordinator) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.userState = userState
        self.loginCoordinator = loginCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let viewController = MG2MyPageViewController(viewModel: MG2MyPageViewModel(userUseCase: userUseCase, userState: userState))
        viewController.coordinator = self
        return viewController
    }

    func routeToEdit(from source: UIViewController) {
        let viewController = MG2MyPageEditViewController(viewModel: MG2MyPageEditViewModel(authUseCase: authUseCase, userState: userState))
        viewController.coordinator = self
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToWeb(destination: MG2WebDestination, from source: UIViewController) {
        let viewController = MG2WebViewController(viewModel: MG2WebViewModel(destination: destination))
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToProfileImageEdit(from source: UIViewController) {
        let viewController = MG2ProfileImageEditViewController(viewModel: MG2ProfileImageEditViewModel(userUseCase: userUseCase, userState: userState))
        viewController.coordinator = self
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToNicknameEdit(from source: UIViewController) {
        source.navigationController?.pushViewController(loginCoordinator.makeNickname(mode: .editing), animated: true)
    }

    func routeToJobEdit(from source: UIViewController) {
        source.navigationController?.pushViewController(loginCoordinator.makeChooseJob(mode: .editing), animated: true)
    }

    func presentProfileImageSelection(imageIDs: [Int], selectedIndex: Int?, onSelection: @escaping (Int) -> Void, from source: UIViewController) {
        loginCoordinator.presentProfileImageSelection(imageIDs: imageIDs, selectedIndex: selectedIndex, onSelection: onSelection, from: source)
    }

    func routeBack(from source: UIViewController) {
        source.navigationController?.popViewController(animated: true)
    }

    func presentLoginGate(from source: UIViewController) {
        loginGateCoordinator.present(from: source)
    }

    func presentWithdrawalConfirmation(onConfirm: @escaping () -> Void, from source: UIViewController) {
        let alert = UIAlertController(title: "정말 회원탈퇴를 하시겠습니까?", message: "회원탈퇴를 하시면 데이터를 복원할 수 없습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { _ in onConfirm() })
        source.present(alert, animated: true)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    func presentUnavailableFeature(_ message: String, from source: UIViewController) {
        alertCoordinator.presentInfo(title: "준비중", message: message, from: source)
    }
}
