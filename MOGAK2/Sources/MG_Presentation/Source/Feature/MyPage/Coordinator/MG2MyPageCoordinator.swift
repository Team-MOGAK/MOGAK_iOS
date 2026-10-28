import UIKit

@MainActor
final class MG2MyPageCoordinator {
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase
    private let userState: MG2UserState
    private let loginCoordinator: MG2LoginCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let todayUseCase: TodayUseCase
    private let adPolicyUseCase: AdPolicyUseCase
    private let adProvider: MG2AdProviding
    private let alertCoordinator = MG2AlertCoordinator()

    init(userUseCase: UserUseCase, authUseCase: AuthUseCase, userState: MG2UserState, loginCoordinator: MG2LoginCoordinator, todayUseCase: TodayUseCase, adPolicyUseCase: AdPolicyUseCase, adProvider: MG2AdProviding) {
        self.todayUseCase = todayUseCase
        self.adPolicyUseCase = adPolicyUseCase
        self.adProvider = adProvider
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.userState = userState
        self.loginCoordinator = loginCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let viewController = MG2MyPageViewController(viewModel: MG2MyPageViewModel(userUseCase: userUseCase, userState: userState, adPolicyUseCase: adPolicyUseCase))
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

    func routeToPushSetting(from source: UIViewController) {
        let viewController = MG2PushSettingViewController(viewModel: MG2PushSettingViewModel(todayUseCase: todayUseCase))
        viewController.coordinator = self
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func openSystemSettings(from source: UIViewController) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        source.view.window?.windowScene?.open(url, options: nil)
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
        let alert = UIAlertController(title: "정말 탈퇴할까요?", message: "탈퇴하면 모다라트와 조각 기록을 되살릴 수 없어요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in onConfirm() })
        source.present(alert, animated: true)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    func presentUnavailableFeature(_ message: String, from source: UIViewController) {
        alertCoordinator.presentInfo(title: "준비 중이에요", message: message, from: source)
    }

    func makeBanner(width: CGFloat, from source: UIViewController) -> UIView {
        adProvider.makeBanner(width: width, rootViewController: source)
    }
}
