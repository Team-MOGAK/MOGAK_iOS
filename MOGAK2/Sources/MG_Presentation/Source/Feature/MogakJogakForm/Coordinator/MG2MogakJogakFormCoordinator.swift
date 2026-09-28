import UIKit

@MainActor
final class MG2MogakJogakFormCoordinator {
    private let useCase: MogakEditingUseCase
    private let alertCoordinator = MG2AlertCoordinator()

    init(useCase: MogakEditingUseCase) {
        self.useCase = useCase
    }

    func routeToMogakCreation(modalartID: Int, from source: UIViewController, onFinish: @escaping () -> Void) {
        pushMogakForm(mode: .create(modalartID: modalartID), from: source, onFinish: onFinish)
    }

    func routeToMogakEditing(mogak: MG2ModalartMogakItemEntity, from source: UIViewController, onFinish: @escaping () -> Void) {
        pushMogakForm(mode: .edit(mogak), from: source, onFinish: onFinish)
    }

    func routeToJogakCreation(mogak: MG2ModalartMogakItemEntity, from source: UIViewController, onFinish: @escaping () -> Void) {
        pushJogakForm(mode: .create(mogak), from: source, onFinish: onFinish)
    }

    func routeToJogakEditing(jogak: MG2JogakDetailEntity, from source: UIViewController, onFinish: @escaping () -> Void) {
        pushJogakForm(mode: .edit(jogak), from: source, onFinish: onFinish)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }

    private func pushMogakForm(mode: MG2MogakFormMode, from source: UIViewController, onFinish: @escaping () -> Void) {
        let viewController = MG2MogakFormViewController(viewModel: MG2MogakFormViewModel(useCase: useCase, mode: mode))
        viewController.coordinator = self
        viewController.onFinish = popping(from: source, after: onFinish)
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    private func pushJogakForm(mode: MG2JogakFormMode, from source: UIViewController, onFinish: @escaping () -> Void) {
        let viewController = MG2JogakFormViewController(viewModel: MG2JogakFormViewModel(useCase: useCase, mode: mode))
        viewController.coordinator = self
        viewController.onFinish = popping(from: source, after: onFinish)
        source.navigationController?.pushViewController(viewController, animated: true)
    }

    private func popping(from source: UIViewController, after onFinish: @escaping () -> Void) -> () -> Void {
        { [weak navigationController = source.navigationController] in
            onFinish()
            navigationController?.popViewController(animated: true)
        }
    }
}
