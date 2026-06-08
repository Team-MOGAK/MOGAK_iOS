import UIKit

final class MG2AppScheduleStartCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let viewModel: MG2AppScheduleStartViewModel

    init(
        navigationController: UINavigationController,
        viewModel: MG2AppScheduleStartViewModel = DIContainer.shared.resolveRequired(MG2AppScheduleStartViewModel.self)
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }

    @discardableResult
    @MainActor
    func start() -> UIViewController {
        viewModel.coordinator = self
        let viewController = MG2AppScheduleStartViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return viewController
    }
}

extension MG2AppScheduleStartCoordinator: MG2AppScheduleStartRouting {
    func showModalartDetail(modalartId: Int) {
        // 상세 화면 전환은 기존 MOGAK1 화면 규격을 유지하면서 순차 적용한다.
    }
}
