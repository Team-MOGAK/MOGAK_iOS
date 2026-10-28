import UIKit

/// 조각시작 · 모다라트 · 마이페이지 세 탭. 시스템 탭 바(UITabBarController)를 그대로 쓴다.
/// iOS 26부터는 시스템이 떠 있는 유리 탭 바로 그리고, 하위 화면으로 들어가면 탭 바가 push와 함께 내려간다.
final class MG2MainTabViewController: UITabBarController {
    enum Tab: Int {
        case scheduleStart, modalart, myPage
    }

    /// 아이콘은 디자인과 같게: 조각시작 `timer` · 모다라트 `checklist` · 마이페이지 `person.crop.circle`.
    init(scheduleStart: UIViewController, modalart: UIViewController, myPage: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        let tabs: [(root: UIViewController, title: String, symbol: String)] = [(scheduleStart, "조각시작", "timer"), (modalart, "모다라트", "checklist"), (myPage, "마이페이지", "person.crop.circle")]
        viewControllers = tabs.map { tab in
            let navigation = MG2NavigationController(rootViewController: tab.root)
            navigation.tabBarItem = UITabBarItem(title: tab.title, image: UIImage(systemName: tab.symbol), selectedImage: nil)
            navigation.tabBarItem.setTitleTextAttributes([.font: T.caption2.font], for: .normal)
            navigation.tabBarItem.setTitleTextAttributes([.font: T.caption2.font], for: .selected)
            return navigation
        }
        // 선택 `accent-deep`, 나머지 `ink`. 배경은 시스템 기본(유리 · 블러)을 그대로 둔다.
        tabBar.tintColor = DS.Color.accentDeep
        tabBar.unselectedItemTintColor = DS.Color.ink
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 전면 광고(앱 열기)를 덮어도 되는 화면인지. 시트가 떠 있거나 판 · 모각 화면, 하위 화면이면 안 된다.
    var allowsFullScreenAd: Bool {
        guard presentedViewController == nil, selectedIndex != Tab.modalart.rawValue, let navigation = selectedViewController as? UINavigationController else { return false }
        return navigation.viewControllers.count == 1
    }

    func select(_ tab: Tab) {
        selectedIndex = tab.rawValue
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewControllers?.forEach(applyContentColumn)
    }

    /// 넓은 화면(Duo 펼침)에서는 내용을 560pt 가운데 열로 모은다. 바탕은 끝까지 칠한다.
    private func applyContentColumn(to viewController: UIViewController) {
        let inset = max((view.bounds.width - MG2MandalaGrid.maxBoardWidth - DS.Space.gutter * 2) / 2, 0)
        guard viewController.additionalSafeAreaInsets.left != inset else { return }
        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

extension UIViewController {
    /// 이 화면을 품은 메인 탭 컨테이너.
    var mainTabController: MG2MainTabViewController? {
        tabBarController as? MG2MainTabViewController
    }
}
