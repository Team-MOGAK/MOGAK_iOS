import UIKit

@MainActor
final class MG2ScheduleStartCoordinator {
    private let useCase: ScheduleStartUseCase
    private let userState: MG2UserState
    private let formCoordinator: MG2MogakJogakFormCoordinator
    private let loginGateCoordinator: MG2LoginGateCoordinator
    private let alertCoordinator = MG2AlertCoordinator()

    init(useCase: ScheduleStartUseCase, userState: MG2UserState, formCoordinator: MG2MogakJogakFormCoordinator, loginCoordinator: MG2LoginCoordinator) {
        self.useCase = useCase
        self.userState = userState
        self.formCoordinator = formCoordinator
        loginGateCoordinator = MG2LoginGateCoordinator(loginCoordinator: loginCoordinator)
    }

    func start() -> UIViewController {
        let viewController = MG2ScheduleStartViewController(viewModel: MG2ScheduleStartViewModel(useCase: useCase, userState: userState))
        viewController.coordinator = self
        return viewController
    }

    func routeToJogakEditing(jogak: MG2JogakDetailEntity, from source: UIViewController) {
        formCoordinator.routeToJogakEditing(jogak: jogak, from: source) {}
    }

    func presentJogakSelection(scheduledDate: Date, from source: UIViewController, onJogaksAdded: @escaping () -> Void) {
        let viewModel = MG2SelectModalartViewModel(useCase: useCase, scheduledDate: scheduledDate)
        let viewController = MG2SelectModalartViewController(viewModel: viewModel, onJogaksAdded: onJogaksAdded)
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

    func routeToJogakSelection(modalart: MG2ModalartOption, modalarts: [MG2ModalartOption], scheduledDate: Date, from source: UIViewController, onJogaksAdded: @escaping () -> Void) {
        let viewModel = MG2SelectJogakViewModel(useCase: useCase, scheduledDate: scheduledDate, modalarts: modalarts, initialModalart: modalart)
        let viewController = MG2SelectJogakViewController(viewModel: viewModel, onJogaksAdded: onJogaksAdded)
        viewController.coordinator = self
        source.navigationController?.pushViewController(viewController, animated: true)
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
        source.tabBarController?.selectedIndex = 1
    }

    func presentJogakOptions(title: String, onEdit: @escaping () -> Void, from source: UIViewController) {
        let viewController = MG2JogakOptionsModal(title: title)
        viewController.onCancel = { [weak viewController] in viewController?.dismiss(animated: true) }
        viewController.onEdit = { [weak viewController] in viewController?.dismiss(animated: true, completion: onEdit) }
        viewController.modalPresentationStyle = .pageSheet

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 220 }]
            sheet.prefersGrabberVisible = true
        }
        source.present(viewController, animated: true)
    }
}
