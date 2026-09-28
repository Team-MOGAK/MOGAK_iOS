import UIKit

@MainActor
final class MG2LoginCoordinator {
    private let authUseCase: AuthUseCase
    private let userUseCase: UserUseCase
    private let userState: MG2UserState
    private let alertCoordinator = MG2AlertCoordinator()

    init(authUseCase: AuthUseCase, userUseCase: UserUseCase, userState: MG2UserState) {
        self.authUseCase = authUseCase
        self.userUseCase = userUseCase
        self.userState = userState
    }

    func start() -> UIViewController {
        makeLogin()
    }

    func makeLogin() -> MG2LoginViewController {
        let viewController = MG2LoginViewController(viewModel: MG2LoginViewModel(authUseCase: authUseCase))
        viewController.coordinator = self
        return viewController
    }

    func makeTerms() -> UIViewController {
        let viewController = MG2TermsAgreeViewController(viewModel: MG2TermsAgreeViewModel(userUseCase: userUseCase))
        viewController.coordinator = self
        return viewController
    }

    func makeNickname(mode: MG2ProfileSetupMode) -> UIViewController {
        let viewController = MG2NicknameViewController(viewModel: MG2NicknameViewModel(userUseCase: userUseCase, userState: userState, mode: mode))
        viewController.coordinator = self
        return viewController
    }

    func makeChooseJob(mode: MG2ProfileSetupMode) -> UIViewController {
        let viewController = MG2ChooseJobViewController(viewModel: MG2ChooseJobViewModel(userUseCase: userUseCase, mode: mode))
        viewController.coordinator = self
        return viewController
    }

    func makeChooseRegion(draft: MG2RegistrationDraft) -> UIViewController {
        let viewController = MG2ChooseRegionViewController(viewModel: MG2ChooseRegionViewModel(userUseCase: userUseCase, draft: draft))
        viewController.coordinator = self
        return viewController
    }

    func routeToNickname(draft: MG2RegistrationDraft, from source: UIViewController) {
        source.navigationController?.pushViewController(makeNickname(mode: .registration(draft)), animated: true)
    }

    func routeToChooseJob(draft: MG2RegistrationDraft, from source: UIViewController) {
        source.navigationController?.pushViewController(makeChooseJob(mode: .registration(draft)), animated: true)
    }

    func routeToChooseRegion(draft: MG2RegistrationDraft, from source: UIViewController) {
        source.navigationController?.pushViewController(makeChooseRegion(draft: draft), animated: true)
    }

    func routeBack(from source: UIViewController) {
        source.navigationController?.popViewController(animated: true)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    func presentLoginError(_ message: String, from source: UIViewController, onDismiss: @escaping () -> Void) {
        alertCoordinator.presentInfo(title: "로그인 실패", message: message, from: source, onDismiss: onDismiss)
    }
}
