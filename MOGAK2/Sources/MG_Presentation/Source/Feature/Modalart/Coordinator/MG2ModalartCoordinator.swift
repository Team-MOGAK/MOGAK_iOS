import UIKit

@MainActor
final class MG2ModalartCoordinator {
    private let useCase: ModalartUseCase
    private let adPolicyUseCase: AdPolicyUseCase
    private let adProvider: MG2AdProviding
    private let userState: MG2UserState
    private let formCoordinator: MG2MogakJogakFormCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let alertCoordinator = MG2AlertCoordinator()

    init(useCase: ModalartUseCase, adPolicyUseCase: AdPolicyUseCase, adProvider: MG2AdProviding, userState: MG2UserState, formCoordinator: MG2MogakJogakFormCoordinator, loginCoordinator: MG2LoginCoordinator) {
        self.useCase = useCase
        self.adPolicyUseCase = adPolicyUseCase
        self.adProvider = adProvider
        self.userState = userState
        self.formCoordinator = formCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let viewController = MG2ModalartMainViewController(viewModel: MG2ModalartMainViewModel(useCase: useCase, userState: userState))
        viewController.coordinator = self
        return viewController
    }

    /// sourceView: 누른 판 칸. iOS 18부터 그 칸에서 확대되며 열리고 닫힐 때 그 칸으로 돌아간다 (시스템 zoom).
    /// iOS 17이나 동작 줄이기에서는 기본 push.
    func routeToMogakDetail(mogaks: [MG2ModalartMogakItemEntity], selectedMogak: MG2ModalartMogakItemEntity, occurrences: [MG2JogakOccurrenceEntity], modalartID: Int, modalartTitle: String, sourceView: UIView? = nil, onExit: @escaping () -> Void, from source: UIViewController) {
        let viewModel = MG2MogakDetailViewModel(useCase: useCase, modalartID: modalartID, modalartTitle: modalartTitle, mogaks: mogaks, selectedMogak: selectedMogak, occurrences: occurrences)
        let viewController = MG2MogakDetailViewController(viewModel: viewModel)
        viewController.coordinator = self
        viewController.onExit = onExit
        if #available(iOS 18, *), let sourceView, !UIAccessibility.isReduceMotionEnabled {
            viewController.preferredTransition = .zoom { [weak sourceView] _ in sourceView }
        }
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToMogakCreation(modalartID: Int, path: [MG2PathItem], from source: UIViewController, onFinish: @escaping () -> Void) {
        formCoordinator.routeToMogakCreation(modalartID: modalartID, path: path, from: source, onFinish: onFinish)
    }

    func routeToMogakEditing(mogak: MG2ModalartMogakItemEntity, path: [MG2PathItem], from source: UIViewController, onFinish: @escaping () -> Void) {
        formCoordinator.routeToMogakEditing(mogak: mogak, path: path, from: source, onFinish: onFinish)
    }

    func routeToJogakCreation(mogak: MG2ModalartMogakItemEntity, path: [MG2PathItem], from source: UIViewController, onFinish: @escaping () -> Void) {
        formCoordinator.routeToJogakCreation(mogak: mogak, path: path, from: source, onFinish: onFinish)
    }

    func routeToJogakEditing(jogak: MG2JogakDetailEntity, path: [MG2PathItem], from source: UIViewController, onFinish: @escaping () -> Void) {
        formCoordinator.routeToJogakEditing(jogak: jogak, path: path, from: source, onFinish: onFinish)
    }

    func presentModalartList(modalarts: [MG2ModalartListItemEntity], onSelection: @escaping (Int) -> Void, onAdd: @escaping () -> Void, from source: UIViewController) {
        let viewController = MG2ModalartListModal(modalarts: modalarts)
        viewController.onDismiss = { [weak viewController] in viewController?.dismiss(animated: true) }
        viewController.onSelection = { [weak viewController] index in
            viewController?.dismiss(animated: true) {
                onSelection(index)
            }
        }
        viewController.onAdd = { [weak viewController] in viewController?.dismiss(animated: true, completion: onAdd) }
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        source.present(viewController, animated: true)
    }

    func presentModalartActions(onAdd: @escaping () -> Void, onDelete: @escaping () -> Void, from source: UIViewController) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = DS.Color.accentDeep
        actionSheet.addAction(UIAlertAction(title: "모다라트 추가", style: .default) { _ in onAdd() })
        actionSheet.addAction(UIAlertAction(title: "현 모다라트 삭제", style: .destructive) { _ in onDelete() })
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        actionSheet.popoverPresentationController?.sourceView = source.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: source.view.bounds.maxX - 32, y: source.view.safeAreaInsets.top + 16, width: 1, height: 1)
        source.present(actionSheet, animated: true)
    }

    func presentModalartTitleEditor(title: String?, color: String, onSubmit: @escaping (String, String) -> Void, from source: UIViewController) {
        let editorViewModel = MG2ModalartTitleEditorViewModel(title: title, color: color)
        let viewController = MG2ModalartTitleEditorModal(viewModel: editorViewModel)
        viewController.onCancel = { [weak viewController] in viewController?.dismiss(animated: true) }
        viewController.onSubmit = { [weak viewController] title, color in
            viewController?.dismiss(animated: true) {
                onSubmit(title, color)
            }
        }
        configureSheet(viewController)
        source.present(viewController, animated: true)
    }

    func presentMissingTitleNotice(from source: UIViewController) {
        let viewController = MG2NeedModalartTitleModal()
        viewController.onConfirm = { [weak viewController] in viewController?.dismiss(animated: true) }
        configureSheet(viewController)
        source.present(viewController, animated: true)
    }

    func presentDeleteConfirmation(onConfirm: @escaping () -> Void, from source: UIViewController) {
        let viewController = MG2AskDeleteModal()
        viewController.onCancel = { [weak viewController] in viewController?.dismiss(animated: true) }
        viewController.onConfirm = { [weak viewController] in viewController?.dismiss(animated: true, completion: onConfirm) }
        configureSheet(viewController)
        source.present(viewController, animated: true)
    }

    func presentDeleteAction(title: String, message: String, onConfirm: @escaping () -> Void, from source: UIViewController) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self, weak source] _ in
            guard let self, let source else { return }
            presentDeleteConfirmation(onConfirm: onConfirm, from: source)
        })
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        actionSheet.popoverPresentationController?.sourceView = source.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: source.view.bounds.midX, y: source.view.bounds.midY, width: 1, height: 1)
        source.present(actionSheet, animated: true)
    }

    func presentMogakActions(mogak: MG2ModalartMogakItemEntity, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void, from source: UIViewController) {
        let viewController = MG2MogakMainBottomModal(mogak: mogak)
        viewController.onEdit = { [weak viewController] in viewController?.dismiss(animated: true, completion: onEdit) }
        viewController.onDelete = { [weak viewController] in viewController?.dismiss(animated: true, completion: onDelete) }
        viewController.onClose = { [weak viewController] in viewController?.dismiss(animated: true) }
        configureSheet(viewController)
        source.present(viewController, animated: true)
    }

    func presentJogakActions(viewData: MG2JogakSummaryViewData, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void, from source: UIViewController) {
        let viewController = MG2JogakSimpleModal(viewData: viewData)
        viewController.onDelete = { [weak viewController] in viewController?.dismiss(animated: true, completion: onDelete) }
        viewController.onEdit = { [weak viewController] in viewController?.dismiss(animated: true, completion: onEdit) }
        viewController.onClose = { [weak viewController] in viewController?.dismiss(animated: true) }
        configureSheet(viewController)
        source.present(viewController, animated: true)
    }

    func presentNoMogaksRemaining(from source: UIViewController) {
        let alert = UIAlertController(title: "마지막 모각을 삭제했어요", message: "모다라트 판으로 돌아갈게요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "판으로 돌아가기", style: .default) { [weak source] _ in source?.navigationController?.popViewController(animated: true) })
        source.present(alert, animated: true)
    }

    func presentLoginGate(from source: UIViewController) {
        loginGateCoordinator.present(from: source)
    }

    func presentFullBoard(modalartTitle: String, mogaks: [MG2ModalartMogakItemEntity], isGuest: Bool, from source: UIViewController) {
        let viewModel = MG2FullBoardViewModel(useCase: useCase, adPolicyUseCase: adPolicyUseCase, modalartTitle: modalartTitle, mogaks: mogaks, isGuest: isGuest)
        let viewController = MG2FullBoardViewController(viewModel: viewModel)
        viewController.coordinator = self
        viewController.modalPresentationStyle = .fullScreen
        source.present(viewController, animated: true)
    }

    /// 81칸을 닫은 뒤가 전면 광고 자리다 (3일째부터 · 하루 2회 · 5분 간격). 판 화면 안에는 광고를 넣지 않는다.
    func closeFullBoard(_ viewController: UIViewController, showsInterstitial: Bool, onInterstitialShown: @escaping () -> Void) {
        let presenter = viewController.presentingViewController
        viewController.dismiss(animated: true) { [adProvider] in
            guard showsInterstitial, let presenter else { return }
            adProvider.presentInterstitial(from: presenter) { shown in if shown { onInterstitialShown() } }
        }
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    /// 시트 높이는 내용에 맞춘다 (`.md-sheet` 위 16 · 아래 20). 글자를 키우면 시트도 같이 커져 잘리지 않는다.
    /// 각 시트는 마지막 요소를 아래 20 이상 띄워 둔다(`lessThanOrEqualTo`).
    private func configureSheet(_ viewController: UIViewController) {
        guard let sheet = viewController.sheetPresentationController else { return }
        sheet.detents = [.custom { [weak viewController] context in
            guard let view = viewController?.view else { return context.maximumDetentValue }
            let fitting = view.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return min(fitting.height, context.maximumDetentValue)
        }]
        sheet.preferredCornerRadius = DS.Radius.sheet
        sheet.prefersGrabberVisible = true
    }
}
