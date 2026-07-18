import UIKit

@MainActor
final class MG2MogakJogakFormCoordinator {
    private let makeMogakViewModel: () -> MG2MogakFormViewModel
    private let makeJogakViewModel: () -> MG2JogakFormViewModel
    private let alertCoordinator = MG2AlertCoordinator()

    init(
        makeMogakViewModel: @escaping () -> MG2MogakFormViewModel,
        makeJogakViewModel: @escaping () -> MG2JogakFormViewModel
    ) {
        self.makeMogakViewModel = makeMogakViewModel
        self.makeJogakViewModel = makeJogakViewModel
    }

    func routeToMogakCreation(
        modalartID: Int,
        delegate: MG2MogakFormDelegate,
        from source: UIViewController
    ) {
        let viewModel = makeMogakViewModel()
        viewModel.prepare(mode: .create(modalartID: modalartID))
        let viewController = MogakFormViewController(
            mode: .create(modalartID: modalartID),
            viewModel: viewModel
        )
        viewController.coordinator = self
        pushMogakForm(viewController, delegate: delegate, from: source)
    }

    func routeToMogakEditing(
        mogak: MG2ModalartMogakItemEntity,
        delegate: MG2MogakFormDelegate,
        from source: UIViewController
    ) {
        let viewModel = makeMogakViewModel()
        viewModel.prepare(mode: .edit(mogak))
        let viewController = MogakFormViewController(
            mode: .edit(mogak),
            viewModel: viewModel
        )
        viewController.coordinator = self
        pushMogakForm(viewController, delegate: delegate, from: source)
    }

    func routeToJogakCreation(
        mogak: MG2ModalartMogakItemEntity,
        delegate: MG2JogakFormDelegate,
        from source: UIViewController
    ) {
        let viewModel = makeJogakViewModel()
        viewModel.prepare(mode: .create(mogak))
        let viewController = JogakFormViewController(
            mode: .create(mogak),
            viewModel: viewModel
        )
        viewController.coordinator = self
        pushJogakForm(viewController, delegate: delegate, from: source)
    }

    func routeToJogakEditing(
        jogak: MG2JogakDetailEntity,
        delegate: MG2JogakFormDelegate?,
        from source: UIViewController
    ) {
        let viewModel = makeJogakViewModel()
        viewModel.prepare(mode: .edit(jogak))
        let viewController = JogakFormViewController(
            mode: .edit(jogak),
            viewModel: viewModel
        )
        viewController.coordinator = self
        pushJogakForm(viewController, delegate: delegate, from: source)
    }

    private func pushMogakForm(
        _ viewController: MogakFormViewController,
        delegate: MG2MogakFormDelegate,
        from source: UIViewController
    ) {
        let navigationController = source.navigationController
        viewController.onFinish = { [weak delegate, weak navigationController] in
            delegate?.mogakFormDidFinish()
            navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func pushJogakForm(
        _ viewController: JogakFormViewController,
        delegate: MG2JogakFormDelegate?,
        from source: UIViewController
    ) {
        let navigationController = source.navigationController
        viewController.onFinish = { [weak delegate, weak navigationController] in
            delegate?.jogakFormDidFinish()
            navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    func presentError(_ error: Error, from source: UIViewController) {
        alertCoordinator.presentError(error, from: source)
    }
}
