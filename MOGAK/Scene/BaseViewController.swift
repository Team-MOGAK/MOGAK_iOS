//
//  BaseViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setupNavViews()
        setupBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func setupNavViews() {
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "454545") // 백버튼 컬러
        
        let leftImage = UIImage(systemName: "book")
        let rightImage = UIImage(systemName: "person")
        
        let leftButtonItem = UIBarButtonItem(image: leftImage, style: .plain, target: self, action: nil)
        let rightButtonItem = UIBarButtonItem(image: rightImage, style: .plain, target: self, action: #selector(showMyPageVC))
        
        navigationItem.leftBarButtonItem = leftButtonItem
        navigationItem.leftBarButtonItem?.tintColor = UIColor(hex: "191919")
        navigationItem.rightBarButtonItem = rightButtonItem
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "454545")
    }
    
    private func setupBackButton() {
        
        let attributes = [NSAttributedString.Key.font: UIFont.pretendard(.bold, size: 20),
                          NSAttributedString.Key.foregroundColor: UIColor(hex: "454545"),
                          NSAttributedString.Key.baselineOffset: -3] as [NSAttributedString.Key : Any]
        
        
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        navigationItem.backBarButtonItem = backButtonItem
        
        navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
    }
    
    @objc private func showMyPageVC() {
        
        self.tabBarController?.tabBar.isHidden = true
        
        
        let myPageVC = MyPageViewController()
        self.navigationController?.pushViewController(myPageVC, animated: true)
    }
    
    
    
}
