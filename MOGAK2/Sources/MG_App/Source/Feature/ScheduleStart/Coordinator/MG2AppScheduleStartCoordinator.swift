import UIKit

@MainActor
final class MG2AppScheduleStartCoordinator: Coordinator {

    let navigationController: UINavigationController

    private let useCase: ScheduleStartUseCase

    init(navigationController: UINavigationController, useCase: ScheduleStartUseCase) {
        self.navigationController = navigationController
        self.useCase = useCase
    }

    @discardableResult
    func start() -> UIViewController {
        let viewModel = MG2AppScheduleStartViewModel(useCase: useCase)
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
