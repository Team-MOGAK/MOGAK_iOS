import UIKit

final class MG2ScheduleStartCoordinator: Coordinator {

    let navigationController: UINavigationController

    private let useCase: ScheduleStartUseCase

    init(navigationController: UINavigationController, useCase: ScheduleStartUseCase) {
        self.navigationController = navigationController
        self.useCase = useCase
    }

    @discardableResult
    func start() -> UIViewController {
        let viewModel = MG2ScheduleStartViewModel(useCase: useCase)
        viewModel.coordinator = self

        let viewController = MG2ScheduleStartViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return viewController
    }
}

extension MG2ScheduleStartCoordinator: MG2ScheduleStartRouting {
    func showModalartDetail(modalartId: Int) {
        // 상세 화면 전환은 기존 MOGAK1 화면 규격을 유지하면서 순차 적용한다.
    }
}
