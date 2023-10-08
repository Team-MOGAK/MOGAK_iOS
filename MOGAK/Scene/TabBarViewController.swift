//
//  TabBarViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit

class TabBarViewController: UITabBarController{
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setupViews()
        
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().backgroundColor = .white
        
    }
    
    private func setupViews() {
        
        let homeTabBarItem = UITabBarItem(title: "조각시작", image: UIImage(named: "start"), selectedImage: UIImage(named: "selectedStart"))
        let modalArtBarItem = UITabBarItem(title: "모다라트", image: UIImage(named: "modalArt"), selectedImage: UIImage(named: ""))
        let reportTabBarItem = UITabBarItem(title: "조각분석", image: UIImage(named: "report"), selectedImage: UIImage(named: "selectedReport"))
        
        let insets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        homeTabBarItem.imageInsets = insets
        modalArtBarItem.imageInsets = insets
        reportTabBarItem.imageInsets = insets
        
        let titleOffset = UIOffset(horizontal: 0, vertical: 10)
        homeTabBarItem.titlePositionAdjustment = titleOffset
        modalArtBarItem.titlePositionAdjustment = titleOffset
        reportTabBarItem.titlePositionAdjustment = titleOffset
        
        let homeVC = generateNavController(vc: ScheduleStartViewController(), tabBarItem: homeTabBarItem)
        let modalArtVC = generateNavController(vc: ModalartMainViewController(), tabBarItem: modalArtBarItem)
        let reportVC = generateNavController(vc: ScheduleReportViewController(), tabBarItem: reportTabBarItem)
        
        self.viewControllers = [homeVC,modalArtVC, reportVC]
        self.selectedIndex = 0
        
    }
    
    fileprivate func generateNavController(vc: UIViewController, tabBarItem: UITabBarItem) -> UINavigationController {
        
        navigationItem.title = title
        
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = tabBarItem
        
        return navController
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 100 // 원하는 탭 바 높이 값으로 수정하세요
        return sizeThatFits
    }
}




































//Preview code
//#if DEBUG
//import SwiftUI
//struct TabBarViewControllerRepresentable: UIViewControllerRepresentable {
//
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        TabBarViewController()
//    }
//}
//@available(iOS 13.0, *)
//struct TabBarViewControllerRepresentable_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            if #available(iOS 14.0, *) {
//                TabBarViewControllerRepresentable()
//                    .ignoresSafeArea()
//                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//                    .previewDevice(PreviewDevice(rawValue: "iPhone se3"))
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//
//    }
//} #endif
