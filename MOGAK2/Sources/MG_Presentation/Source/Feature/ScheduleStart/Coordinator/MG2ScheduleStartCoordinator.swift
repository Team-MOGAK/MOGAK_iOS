import UIKit

final class MG2ScheduleStartCoordinator: MG2PresentationCoordinator {
    typealias JogakSelectionViewModelFactory = () -> MG2JogakSelectionViewModel

    private let viewModel: MG2ScheduleStartViewModel
    private let makeJogakSelectionViewModel: JogakSelectionViewModelFactory
    private let formCoordinator: MG2MogakJogakFormCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let alertCoordinator = MG2AlertCoordinator()

    init(
        viewModel: MG2ScheduleStartViewModel,
        makeJogakSelectionViewModel: @escaping JogakSelectionViewModelFactory,
        formCoordinator: MG2MogakJogakFormCoordinator,
        loginCoordinator: MG2LoginCoordinator
    ) {
        self.viewModel = viewModel
        self.makeJogakSelectionViewModel = makeJogakSelectionViewModel
        self.formCoordinator = formCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let viewController = ScheduleStartViewController(viewModel: viewModel)
        viewController.coordinator = self
        return viewController
    }

    func routeToJogakEditing(
        jogak: MG2JogakDetailEntity,
        from source: UIViewController
    ) {
        formCoordinator.routeToJogakEditing(
            jogak: jogak,
            delegate: nil,
            from: source
        )
    }

    func presentJogakSelection(
        from source: UIViewController,
        onJogaksAdded: @escaping () -> Void
    ) {
        let selectionViewModel = makeJogakSelectionViewModel()
        let viewController = SelectModalartViewController(
            viewModel: selectionViewModel,
            onJogaksAdded: onJogaksAdded
        )
        viewController.coordinator = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.delegate = source as? UISheetPresentationControllerDelegate
            sheet.prefersGrabberVisible = true
        }
        source.present(navigationController, animated: true)
    }

    func routeToJogakSelection(
        modalart: MG2ModalartOption,
        viewModel: MG2JogakSelectionViewModel,
        from source: UIViewController,
        onJogaksAdded: @escaping () -> Void
    ) {
        let viewController = SelectJogakModal(
            viewModel: viewModel,
            initialModalart: modalart,
            onJogaksAdded: onJogaksAdded
        )
        viewController.coordinator = self
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    func finishJogakSelection(
        from source: UIViewController,
        onFinished: @escaping () -> Void
    ) {
        source.dismiss(animated: true, completion: onFinished)
    }

    func presentLoginGate(from source: UIViewController) {
        loginGateCoordinator.present(from: source)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    func routeToModalartTab(from source: UIViewController) {
        source.tabBarController?.selectedIndex = 1
    }

    func presentJogakOptions(
        title: String,
        jogak: MG2JogakDetailEntity,
        from source: UIViewController
    ) {
        let viewController = JogakOptionsModal(title: title)
        viewController.onCancel = { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        viewController.onEdit = { [weak self, weak source, weak viewController] in
            viewController?.dismiss(animated: true) {
                guard let self, let source else { return }
                self.routeToJogakEditing(jogak: jogak, from: source)
            }
        }
        viewController.modalPresentationStyle = .pageSheet

        if #available(iOS 16.0, *), let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 200 }]
            sheet.prefersGrabberVisible = true
        }
        source.present(viewController, animated: true)
    }
}
