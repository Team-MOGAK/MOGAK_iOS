import UIKit

@MainActor
final class MG2ScheduleStartCoordinator {
    private let useCase: ScheduleStartUseCase
    private let todayUseCase: TodayUseCase
    private let adPolicyUseCase: AdPolicyUseCase
    private let adProvider: MG2AdProviding
    private let userState: MG2UserState
    private let formCoordinator: MG2MogakJogakFormCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let alertCoordinator = MG2AlertCoordinator()

    init(useCase: ScheduleStartUseCase, todayUseCase: TodayUseCase, adPolicyUseCase: AdPolicyUseCase, adProvider: MG2AdProviding, userState: MG2UserState, formCoordinator: MG2MogakJogakFormCoordinator, loginCoordinator: MG2LoginCoordinator) {
        self.useCase = useCase
        self.todayUseCase = todayUseCase
        self.adPolicyUseCase = adPolicyUseCase
        self.adProvider = adProvider
        self.userState = userState
        self.formCoordinator = formCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let viewController = MG2ScheduleStartViewController(viewModel: MG2ScheduleStartViewModel(useCase: useCase, todayUseCase: todayUseCase, adPolicyUseCase: adPolicyUseCase, userState: userState))
        viewController.coordinator = self
        return viewController
    }

    func routeToJogakEditing(jogak: MG2JogakDetailEntity, path: [MG2PathItem], from source: UIViewController) {
        formCoordinator.routeToJogakEditing(jogak: jogak, path: path, from: source) {}
    }

    func presentJogakSelection(scheduledDate: Date, from source: UIViewController, onJogaksAdded: @escaping () -> Void) {
        let viewModel = MG2SelectModalartViewModel(useCase: useCase, scheduledDate: scheduledDate)
        let viewController = MG2SelectModalartViewController(viewModel: viewModel, onJogaksAdded: onJogaksAdded)
        viewController.coordinator = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = DS.Radius.sheet
            sheet.delegate = source as? UISheetPresentationControllerDelegate
            sheet.prefersGrabberVisible = true
        }
        source.present(navigationController, animated: true)
    }

    func routeToJogakSelection(modalart: MG2ModalartOption, modalarts: [MG2ModalartOption], scheduledDate: Date, from source: UIViewController, onJogaksAdded: @escaping () -> Void) {
        let viewModel = MG2SelectJogakViewModel(useCase: useCase, scheduledDate: scheduledDate, modalarts: modalarts, initialModalart: modalart)
        let viewController = MG2SelectJogakViewController(viewModel: viewModel, onJogaksAdded: onJogaksAdded)
        viewController.coordinator = self
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func closeJogakSelection(from source: UIViewController) {
        source.dismiss(animated: true)
    }

    func finishJogakSelection(from source: UIViewController, onFinished: @escaping () -> Void) {
        source.dismiss(animated: true, completion: onFinished)
    }

    func presentLoginGate(from source: UIViewController) {
        loginGateCoordinator.present(from: source)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    func routeToModalartTab(from source: UIViewController) {
        source.mainTabController?.select(.modalart)
    }

    func presentJogakOptions(title: String, onEdit: @escaping () -> Void, from source: UIViewController) {
        let viewController = MG2JogakOptionsModal(title: title)
        viewController.onCancel = { [weak viewController] in viewController?.dismiss(animated: true) }
        viewController.onEdit = { [weak viewController] in viewController?.dismiss(animated: true, completion: onEdit) }
        viewController.modalPresentationStyle = .pageSheet

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 230 }]
            sheet.preferredCornerRadius = DS.Radius.sheet
            sheet.prefersGrabberVisible = true
        }
        source.present(viewController, animated: true)
    }

    func presentCelebration(done: Int, completedCount: Int, from source: UIViewController, onConfirmed: @escaping () -> Void) {
        let viewController = MG2CelebrationModal(done: done, completedCount: completedCount)
        viewController.onConfirm = { [weak viewController] in viewController?.dismiss(animated: true, completion: onConfirmed) }
        source.present(viewController, animated: true)
    }

    func presentReminderOffer(from source: UIViewController, onAccept: @escaping () -> Void, onDecline: @escaping () -> Void) {
        let viewController = MG2ReminderOfferModal()
        viewController.onAccept = { [weak viewController] in viewController?.dismiss(animated: true, completion: onAccept) }
        viewController.onDecline = { [weak viewController] in viewController?.dismiss(animated: true, completion: onDecline) }
        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 360 }]
            sheet.preferredCornerRadius = DS.Radius.sheet
            sheet.prefersGrabberVisible = true
        }
        source.present(viewController, animated: true)
    }

    /// 지난 날 기록 열기: 사용자가 고를 때만 보상형 광고.
    func presentRewardedUnlock(from source: UIViewController, onUnlocked: @escaping () -> Void) {
        let alert = UIAlertController(title: "지난 기록 열기", message: "광고를 끝까지 보면 이 날 조각을 체크할 수 있어요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "광고 보고 열기", style: .default) { [weak self, weak source] _ in
            guard let self, let source else { return }
            adProvider.presentRewarded(from: source) { earned in if earned { onUnlocked() } }
        })
        source.present(alert, animated: true)
    }

    func presentInterstitial(from source: UIViewController, completion: @escaping (Bool) -> Void) {
        adProvider.presentInterstitial(from: source, completion: completion)
    }

    func loadNativeAd(from source: UIViewController, completion: @escaping (UIView?) -> Void) {
        adProvider.loadNativeAd(rootViewController: source, completion: completion)
    }
}
