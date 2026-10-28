import SnapKit
import UIKit

/// 조각시작 · 모다라트 · 마이페이지 세 탭과 떠 있는 탭 바.
/// 펼친 Duo 가로(넓고 가로가 긴 화면)에서는 2단: 왼쪽 홈/마이 · 가운데 40pt 접힘 띠 · 오른쪽 판, 탭 바도 칸마다 하나씩(2개).
final class MG2MainTabViewController: UIViewController {
    enum Tab: Int {
        case scheduleStart, modalart, myPage
    }

    private static let dualMinimumWidth: CGFloat = 900
    private static let hingeWidth: CGFloat = 40
    private static let compactBarWidth: CGFloat = 300
    private static let dualBarWidth: CGFloat = 210
    private static let boardBarWidth: CGFloat = 120

    let navigationControllers: [UINavigationController]
    /// 다음 push 한 번에만 쓸 전환 (판 → 모각 확대). Coordinator가 넣는다.
    var nextPushTransition: UIViewControllerAnimatedTransitioning?
    private(set) var selectedTab = Tab.scheduleStart
    /// 2단일 때 왼쪽에 보일 탭 (조각시작 또는 마이페이지).
    private var leadingTab = Tab.scheduleStart
    private var isDual = false

    private let compactBar = MG2FloatingTabBar(items: [
        .init(index: Tab.scheduleStart.rawValue, title: "조각시작", symbol: "checklist"),
        .init(index: Tab.modalart.rawValue, title: "모다라트", symbol: "square.grid.3x3"),
        .init(index: Tab.myPage.rawValue, title: "마이페이지", symbol: "person.crop.circle")
    ])
    private let dualBar = MG2FloatingTabBar(items: [
        .init(index: Tab.scheduleStart.rawValue, title: "조각시작", symbol: "checklist"),
        .init(index: Tab.myPage.rawValue, title: "마이페이지", symbol: "person.crop.circle")
    ])
    /// 2단 오른쪽(판) 칸의 탭 바.
    private let boardBar = MG2FloatingTabBar(items: [
        .init(index: Tab.modalart.rawValue, title: "모다라트", symbol: "square.grid.3x3")
    ])
    private let hingeView = UIView()

    init(navigationControllers: [UINavigationController]) {
        self.navigationControllers = navigationControllers
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var selectedViewController: UIViewController? { navigationControllers[selectedTab.rawValue] }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.canvas
        hingeView.backgroundColor = DS.Color.line
        navigationControllers.forEach { navigation in
            addChild(navigation)
            navigation.didMove(toParent: self)
            navigation.delegate = self
        }
        view.addSubviews(hingeView, compactBar, dualBar, boardBar)
        compactBar.onSelect = { [weak self] in self?.select(Tab(rawValue: $0) ?? .scheduleStart) }
        dualBar.onSelect = compactBar.onSelect
        boardBar.onSelect = compactBar.onSelect
        render()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let dual = view.bounds.width >= Self.dualMinimumWidth && view.bounds.width > view.bounds.height
        if dual != isDual {
            isDual = dual
            render()
        }
        layoutPanes()
    }

    func select(_ tab: Tab) {
        if tab != .modalart { leadingTab = tab }
        selectedTab = tab
        render()
    }

    private func visibleTabs() -> [Tab] {
        isDual ? [leadingTab, .modalart] : [selectedTab]
    }

    private func render() {
        let visible = visibleTabs()
        for (index, navigation) in navigationControllers.enumerated() {
            let isVisible = visible.contains(Tab(rawValue: index) ?? .scheduleStart)
            if isVisible, navigation.view.superview == nil {
                view.insertSubview(navigation.view, at: 0)
            } else if !isVisible {
                navigation.view.removeFromSuperview()
            }
        }
        hingeView.isHidden = !isDual
        compactBar.select(selectedTab.rawValue)
        dualBar.select(leadingTab.rawValue)
        boardBar.select(selectedTab == .modalart ? Tab.modalart.rawValue : -1)
        updateBars()
        view.setNeedsLayout()
    }

    private func layoutPanes() {
        let bounds = view.bounds
        if isDual {
            let paneWidth = (bounds.width - Self.hingeWidth) / 2
            navigationControllers[leadingTab.rawValue].view.frame = CGRect(x: 0, y: 0, width: paneWidth, height: bounds.height)
            hingeView.frame = CGRect(x: paneWidth, y: 0, width: Self.hingeWidth, height: bounds.height)
            navigationControllers[Tab.modalart.rawValue].view.frame = CGRect(x: paneWidth + Self.hingeWidth, y: 0, width: paneWidth, height: bounds.height)
            layoutBar(dualBar, width: Self.dualBarWidth, centerX: paneWidth / 2)
            layoutBar(boardBar, width: Self.boardBarWidth, centerX: paneWidth + Self.hingeWidth + paneWidth / 2)
        } else {
            navigationControllers[selectedTab.rawValue].view.frame = bounds
            layoutBar(compactBar, width: Self.compactBarWidth, centerX: bounds.midX)
        }
    }

    private func layoutBar(_ bar: UIView, width: CGFloat, centerX: CGFloat) {
        let y = view.bounds.height - view.safeAreaInsets.bottom - DS.Space.tabBottom - DS.Size.tabBar
        bar.frame = CGRect(x: centerX - width / 2, y: y, width: width, height: DS.Size.tabBar)
    }

    /// 탭 루트 화면에서만 탭 바를 보이고, 그만큼 아래 안전 영역을 늘린다.
    private func updateBars() {
        let leadingIsRoot = navigationControllers[(isDual ? leadingTab : selectedTab).rawValue].viewControllers.count <= 1
        let boardIsRoot = navigationControllers[Tab.modalart.rawValue].viewControllers.count <= 1
        compactBar.isHidden = isDual || !leadingIsRoot
        dualBar.isHidden = !isDual || !leadingIsRoot
        boardBar.isHidden = !isDual || !boardIsRoot
        let barInset = DS.Size.tabBar + DS.Space.tabBottom
        for navigation in navigationControllers {
            navigation.additionalSafeAreaInsets.bottom = navigation.viewControllers.count <= 1 ? barInset : 0
        }
    }
}

extension MG2MainTabViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        updateBars()
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        defer { nextPushTransition = nil }
        guard operation == .push, !UIAccessibility.isReduceMotionEnabled else { return nil }
        return nextPushTransition
    }
}

extension UIViewController {
    /// 이 화면을 품은 메인 탭 컨테이너.
    var mainTabController: MG2MainTabViewController? {
        var current = parent
        while let viewController = current {
            if let main = viewController as? MG2MainTabViewController { return main }
            current = viewController.parent
        }
        return nil
    }
}
