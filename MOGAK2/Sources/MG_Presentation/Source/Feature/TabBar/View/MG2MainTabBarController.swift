import UIKit

final class MG2MainTabBarController: UITabBarController {

    private let viewModel: MG2MainTabBarViewModel
    private let navigationControllers: [UINavigationController]

    init(
        viewModel: MG2MainTabBarViewModel,
        navigationControllers: [UINavigationController]
    ) {
        self.viewModel = viewModel
        self.navigationControllers = navigationControllers
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
        let controllers = zip(navigationControllers, viewModel.items).map { nav, item in
            let tab = UITabBarItem(
                title: item.title,
                image: UIImage(named: item.imageName),
                selectedImage: UIImage(named: item.selectedImageName)
            )
            nav.tabBarItem = tab
            return nav
        }
        viewControllers = controllers
        selectedIndex = 0
    }
}
