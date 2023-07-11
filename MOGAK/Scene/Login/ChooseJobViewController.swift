//
//  ChooseJobViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import UIKit

class ChooseJobViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        self.configureNavBar()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    

}
