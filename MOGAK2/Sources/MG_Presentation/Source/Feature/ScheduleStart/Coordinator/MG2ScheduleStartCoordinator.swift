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
    private var preparedViewModel: MG2ScheduleStartViewModel?
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
        let viewModel = preparedViewModel ?? makeViewModel()
        preparedViewModel = nil
        let viewController = MG2ScheduleStartViewController(viewModel: viewModel)
        viewController.coordinator = self
        return viewController
    }

    /// 앱을 켤 때 스플래시가 기다리는 동안 홈 첫 화면 데이터를 미리 불러 둔다. 실패하면 홈이 다시 부른다.
    func prepare() async {
        let viewModel = makeViewModel()
        try? await viewModel.load(date: Date())
        preparedViewModel = viewModel
    }

    private func makeViewModel() -> MG2ScheduleStartViewModel {
        MG2ScheduleStartViewModel(useCase: useCase, todayUseCase: todayUseCase, adPolicyUseCase: adPolicyUseCase, userState: userState)
    }

    func routeToJogakEditing(jogak: MG2JogakDetailEntity, path: [MG2PathItem], from source: UIViewController) {
        formCoordinator.routeToJogakEditing(jogak: jogak, path: path, from: source) {}
    }

    /// 시트를 바로 띄운다. 모다라트 목록은 시트가 스켈레톤을 띄운 채 불러온다.
    func presentJogakSelection(scheduledDate: Date, from source: UIViewController, onJogaksAdded: @escaping () -> Void) {
        let viewModel = MG2SelectModalartViewModel(useCase: useCase, scheduledDate: scheduledDate)
        let viewController = MG2SelectModalartViewController(viewModel: viewModel, onJogaksAdded: onJogaksAdded)
        viewController.coordinator = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            // 목록이 길어도 끌어서 커지지 않는 한 가지 높이.
            sheet.detents = [.custom { context in context.maximumDetentValue * 0.75 }]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = DS.Radius.sheet
            sheet.delegate = source as? UISheetPresentationControllerDelegate
            sheet.prefersGrabberVisible = true
        }
        source.present(navigationController, animated: true)
    }

    /// 바로 넘어간다. 고른 모다라트의 조각은 다음 화면이 스켈레톤을 띄운 채 불러온다.
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
        presentFittingSheet(viewController, from: source)
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
        presentFittingSheet(viewController, from: source)
    }

    /// 내용 높이에 맞춘 시트 (띄우기 전에 한 번 재서 고정, 끌어도 늘어나지 않음).
    private func presentFittingSheet(_ viewController: UIViewController, from source: UIViewController) {
        viewController.configureDesignSheetFittingContent(width: source.view.bounds.width)
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
}
