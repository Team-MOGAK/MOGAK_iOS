//
//  LoginViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/08.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
    
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAK"
        label.font = UIFont.pretendard(.regular, size: 28)
        return label
    }()
    
    private let loginLabel : UILabel = {
        let label = UILabel()
        label.text = "로그인 하기"
        label.font = UIFont.pretendard(.regular, size: 28)
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "모두가 각자의 성장을 응원하기위한 여정을 시작해 볼까요?"
        label.font = UIFont.pretendard(.regular, size: 14)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "f9f9f9")
        self.configureNavBar()
        self.configureLabel()
        
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubviews(mogakLabel, loginLabel, subLabel)
        
        mogakLabel.snp.makeConstraints{ make in
            make.leading.equalTo(view).offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(48)
        }
        
        loginLabel.snp.makeConstraints{ make in
            make.leading.equalTo(view).offset(20)
            make.top.equalTo(mogakLabel.snp.bottom).offset(16)
        }
        
        subLabel.snp.makeConstraints{ make in
            make.leading.equalTo(view).offset(20)
            make.top.equalTo(loginLabel.snp.bottom).offset(8)
        }
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
