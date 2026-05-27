import UIKit

final class MG2MainTabBarController: UITabBarController {

    private let viewModel: MG2MainTabBarViewModel

    init(viewModel: MG2MainTabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
    }

    private func configureTabs() {
        let controllers = zip(viewModel.viewControllers, viewModel.items).map { vc, item in
            let nav = UINavigationController(rootViewController: vc)
            let tab = UITabBarItem(title: item.title, image: item.image, selectedImage: item.selectedImage)
            nav.tabBarItem = tab
            return nav
        }
        viewControllers = controllers
        selectedIndex = 0
    }
}
