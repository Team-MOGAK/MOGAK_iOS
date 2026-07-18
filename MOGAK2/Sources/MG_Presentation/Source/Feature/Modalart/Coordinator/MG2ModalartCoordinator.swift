import UIKit

final class MG2ModalartCoordinator: MG2PresentationCoordinator {
    typealias MogakDetailViewModelFactory = (
        Int,
        [MG2ModalartMogakItemEntity],
        MG2ModalartMogakItemEntity,
        [MG2JogakDetailEntity]
    ) -> MG2MogakDetailViewModel

    private let viewModel: MG2ModalartViewModel
    private let makeMogakDetailViewModel: MogakDetailViewModelFactory
    private let formCoordinator: MG2MogakJogakFormCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let alertCoordinator = MG2AlertCoordinator()

    init(
        viewModel: MG2ModalartViewModel,
        makeMogakDetailViewModel: @escaping MogakDetailViewModelFactory,
        formCoordinator: MG2MogakJogakFormCoordinator,
        loginCoordinator: MG2LoginCoordinator
    ) {
        self.viewModel = viewModel
        self.makeMogakDetailViewModel = makeMogakDetailViewModel
        self.formCoordinator = formCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let viewController = ModalartMainViewController(viewModel: viewModel)
        viewController.coordinator = self
        return viewController
    }

    func routeToMogakDetail(
        mogaks: [MG2ModalartMogakItemEntity],
        selectedMogak: MG2ModalartMogakItemEntity,
        jogaks: [MG2JogakDetailEntity],
        modalartID: Int,
        onExit: @escaping () -> Void,
        from source: UIViewController
    ) {
        let detailViewModel = makeMogakDetailViewModel(
            modalartID,
            mogaks,
            selectedMogak,
            jogaks
        )
        let viewController = MogakMainViewController(viewModel: detailViewModel)
        viewController.coordinator = self
        viewController.onExit = onExit
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToMogakCreation(
        modalartID: Int,
        delegate: MG2MogakFormDelegate,
        from source: UIViewController
    ) {
        formCoordinator.routeToMogakCreation(
            modalartID: modalartID,
            delegate: delegate,
            from: source
        )
    }

    func routeToMogakEditing(
        mogak: MG2ModalartMogakItemEntity,
        delegate: MG2MogakFormDelegate,
        from source: UIViewController
    ) {
        formCoordinator.routeToMogakEditing(
            mogak: mogak,
            delegate: delegate,
            from: source
        )
    }

    func routeToJogakCreation(
        mogak: MG2ModalartMogakItemEntity,
        delegate: MG2JogakFormDelegate,
        from source: UIViewController
    ) {
        formCoordinator.routeToJogakCreation(
            mogak: mogak,
            delegate: delegate,
            from: source
        )
    }

    func routeToJogakEditing(
        jogak: MG2JogakDetailEntity,
        delegate: MG2JogakFormDelegate,
        from source: UIViewController
    ) {
        formCoordinator.routeToJogakEditing(
            jogak: jogak,
            delegate: delegate,
            from: source
        )
    }

    func presentModalartList(
        modalarts: [MG2ModalartListItemEntity],
        onSelection: @escaping (Int) -> Void,
        onAdd: @escaping () -> Void,
        from source: UIViewController
    ) {
        let viewController = ShowModalArtListModal(
            modalarts: modalarts,
            includesAddAction: true
        )
        viewController.onDismiss = { [weak viewController] in
            viewController?.dismiss(animated: false)
        }
        viewController.onSelection = { [weak viewController] _, index in
            viewController?.dismiss(animated: false) {
                onSelection(index)
            }
        }
        viewController.onAdd = { [weak viewController] in
            viewController?.dismiss(animated: false, completion: onAdd)
        }
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        source.present(viewController, animated: false)
    }

    func presentModalartTitleEditor(
        title: String?,
        color: String,
        onSubmit: @escaping (String, String) -> Void,
        from source: UIViewController
    ) {
        let editorViewModel = MG2ModalartTitleEditorViewModel(title: title, color: color)
        let viewController = SetModalartTitleModal(viewModel: editorViewModel)
        viewController.onCancel = { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        viewController.onSubmit = { [weak viewController] title, color in
            viewController?.dismiss(animated: true) {
                onSubmit(title, color)
            }
        }
        configureSheet(viewController, height: 292)
        source.present(viewController, animated: true)
    }

    func presentMissingTitleNotice(from source: UIViewController) {
        let viewController = NeedModalArtMainTitleModal()
        viewController.onConfirm = { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        configureSheet(viewController, height: 200)
        source.present(viewController, animated: true)
    }

    func presentDeleteConfirmation(
        onConfirm: @escaping () -> Void,
        from source: UIViewController
    ) {
        let viewController = AskDeleteModal()
        viewController.onCancel = { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        viewController.onConfirm = { [weak viewController] in
            viewController?.dismiss(animated: true, completion: onConfirm)
        }
        configureSheet(viewController, height: 239)
        source.present(viewController, animated: true)
    }

    func presentDeleteAction(
        title: String,
        message: String,
        onConfirm: @escaping () -> Void,
        from source: UIViewController
    ) {
        let actionSheet = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self, weak source] _ in
            guard let self, let source else { return }
            presentDeleteConfirmation(onConfirm: onConfirm, from: source)
        })
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        actionSheet.popoverPresentationController?.sourceView = source.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(
            x: source.view.bounds.midX,
            y: source.view.bounds.midY,
            width: 1,
            height: 1
        )
        source.present(actionSheet, animated: true)
    }

    func presentMogakActions(
        mogak: MG2ModalartMogakItemEntity,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        from source: UIViewController
    ) {
        let viewController = MogakMainBottomModalViewController(mogak: mogak)
        viewController.onEdit = { [weak viewController] _ in
            viewController?.dismiss(animated: true, completion: onEdit)
        }
        viewController.onDelete = { [weak viewController] in
            viewController?.dismiss(animated: true, completion: onDelete)
        }
        configureSheet(viewController, height: 200)
        source.present(viewController, animated: true)
    }

    func presentJogakActions(
        viewData: MG2JogakSummaryViewData,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        from source: UIViewController
    ) {
        let viewController = JogakSimpleModalViewController(viewData: viewData)
        viewController.onDelete = { [weak viewController] in
            viewController?.dismiss(animated: true, completion: onDelete)
        }
        viewController.onEdit = { [weak viewController] in
            viewController?.dismiss(animated: true, completion: onEdit)
        }
        configureSheet(viewController, height: viewData.isRoutine ? 238 : 200)
        source.present(viewController, animated: true)
    }

    func presentNoMogaksRemaining(from source: UIViewController) {
        let alert = UIAlertController(
            title: "마지막 모각을 삭제하셨습니다",
            message: "메인 모다라트 화면으로 이동합니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak source] _ in
            source?.navigationController?.popViewController(animated: true)
        })
        source.present(alert, animated: true)
    }

    func presentLoginGate(from source: UIViewController) {
        loginGateCoordinator.present(from: source)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    private func configureSheet(_ viewController: UIViewController, height: CGFloat) {
        guard let sheet = viewController.sheetPresentationController else { return }
        if #available(iOS 16.0, *) {
            sheet.detents = [.custom { _ in height }]
        } else {
            sheet.detents = [.medium()]
        }
        sheet.prefersGrabberVisible = true
    }
}
