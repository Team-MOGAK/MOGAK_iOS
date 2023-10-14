//
//  MyHistoryViewController.swift
//  MOGAK
//
//  Created by 이재혁 on 10/11/23.
//

import UIKit
import SnapKit

class MyHistoryViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    
}

//#Preview("MyHistory") {
//    let controller = MyHistoryViewController()
//    return controller
//}
