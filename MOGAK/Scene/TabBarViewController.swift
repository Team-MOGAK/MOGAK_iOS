//
//  TabBarViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().backgroundColor = .white
    }
    
    private func setupViews() {
        
        let homeTabBarItem = UITabBarItem(title: "피드", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        let networkingTabBarItem = UITabBarItem(title: "네트워킹", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        let routineStartTabBarItem = UITabBarItem(title: "루틴시작", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        let routineRegisterTabBarItem = UITabBarItem(title: "루틴등록", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        
        let homeVC = generateNavController(vc: FeedViewController(), tabBarItem: homeTabBarItem)
        let networkingVC = generateNavController(vc: NetworkingViewController(), tabBarItem: networkingTabBarItem)
        let RoutineStartVC = generateNavController(vc: RoutineStartViewController(), tabBarItem: routineStartTabBarItem)
        let RoutineRegisterVC = generateNavController(vc: RoutineRegisterViewController(), tabBarItem: routineRegisterTabBarItem)
        
        self.viewControllers = [homeVC, networkingVC, RoutineStartVC, RoutineRegisterVC]
        self.selectedIndex = 0
        
    }
    
    fileprivate func generateNavController(vc: UIViewController, tabBarItem: UITabBarItem) -> UINavigationController {
        
        navigationItem.title = title
        
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = tabBarItem
        
        return navController
    }
    
    
    
    
}
