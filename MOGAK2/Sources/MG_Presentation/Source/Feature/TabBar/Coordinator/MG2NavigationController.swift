import UIKit

/// 탭 안의 내비게이션. 하위 화면으로 들어갈 때 시스템 탭 바를 함께 내린다.
final class MG2NavigationController: UINavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !viewControllers.isEmpty { viewController.hidesBottomBarWhenPushed = true }
        super.pushViewController(viewController, animated: animated)
    }
}
