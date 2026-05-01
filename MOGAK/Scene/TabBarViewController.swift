//
//  TabBarViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import Alamofire

#if false
// Legacy MOGAK1 implementation (inactive after 1:1 migration to MG_Presentation).
class TabBarViewController: UITabBarController{
    // Legacy MOGAK1 tab bar.
    // MOGAK2 active route: MG2MainTabBarController (SceneDelegate switched).
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setupViews()
        self.setUpTabBar()
    }
    
    //MARK: - 탭바 색상 설정
    private func setUpTabBar() {
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().backgroundColor = .white
    }
    
    //MARK: - 탭바 만들어주기
    private func setupViews() {
        let homeTabBarItem = UITabBarItem(title: "조각시작", image: UIImage(named: "start"), selectedImage: UIImage(named: "selectedStart"))
        let modalArtBarItem = UITabBarItem(title: "모다라트", image: UIImage(named: "modalArt"), selectedImage: UIImage(named: ""))
//        let reportTabBarItem = UITabBarItem(title: "마이 히스토리", image: UIImage(named: "History"), selectedImage: UIImage(named: "selectedHistory"))
        let mypageTabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(named: "mypage"), selectedImage: UIImage(named: "selectedMypage"))
        
        let insets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        
        homeTabBarItem.imageInsets = insets
        modalArtBarItem.imageInsets = insets
//        reportTabBarItem.imageInsets = insets
        mypageTabBarItem.imageInsets = insets
        
        let titleOffset = UIOffset(horizontal: 0, vertical: 10)
        homeTabBarItem.titlePositionAdjustment = titleOffset
        modalArtBarItem.titlePositionAdjustment = titleOffset
//        reportTabBarItem.titlePositionAdjustment = titleOffset
        mypageTabBarItem.titlePositionAdjustment = titleOffset
        
        let homeVC = generateNavController(vc: ScheduleStartViewController(), tabBarItem: homeTabBarItem)
        let modalArtVC = generateNavController(vc: ModalartMainViewController(), tabBarItem: modalArtBarItem)
//        let reportVC = generateNavController(vc: MyHistoryViewController(), tabBarItem: reportTabBarItem)
        let mypageVC = generateNavController(vc: MyPageViewController(), tabBarItem: mypageTabBarItem)
    
//        self.viewControllers = [homeVC, modalArtVC, reportVC, mypageVC]
        self.viewControllers = [homeVC, modalArtVC, mypageVC]
        self.selectedIndex = 0
    }
    
    //MARK: - 각각의 탭바의 아이템에 navigationController달아주기
    fileprivate func generateNavController(vc: UIViewController, tabBarItem: UITabBarItem) -> UINavigationController {
        let navController = UINavigationController(rootViewController: vc) //탭바 아이템마다 각각의 navigationViewConroller달아주기
        navController.tabBarItem = tabBarItem
        
        return navController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupTabBar()
        print("\(self.tabBar.frame.size.height) viewDidLayoutSubviews 탭바 높이")
    }

    private func adjustTabBarItemLayout(imageInset: UIEdgeInsets, titleOffset: UIOffset) {
            guard let items = tabBar.items else { return }
            
            for item in items {
                item.imageInsets = imageInset
                item.titlePositionAdjustment = titleOffset
            }
        }
        
        private func setupTabBar() {
            guard let screenHeight = view.window?.windowScene?.screen.bounds.size.height else { return }
            if screenHeight == 667 {
    //            self.tabBar.frame.size.height = 90
                adjustTabBarItemLayout(imageInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), titleOffset: UIOffset(horizontal: 0, vertical: 0))
            } else {
    //            self.tabBar.frame.size.height = 100
            }
        }
}




































//Preview code
#endif
