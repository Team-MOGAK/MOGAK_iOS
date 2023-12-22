//
//  LoginViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/08.
//

import UIKit
import SnapKit
import AuthenticationServices
import Alamofire
import Combine

class LoginViewController: UIViewController {
    
    let registerUserInfo = RegisterUserInfo.shared
    var cancellables = Set<AnyCancellable>()
    
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "모두가 각자의 성장을\n응원하기 위한\n여정을 시작해볼까요?"
        label.numberOfLines = 3
        label.textAlignment = .center
        label.font = UIFont.pretendard(.regular, size: 30)
        label.asFont(targetString: "모두가 각자의 성장을", font: UIFont.pretendard(.bold, size: 30))
        return label
    }()
    
    private let loginImage = UIImageView().then {
        $0.image = UIImage(named: "LoginLogo")
    }
    
    private lazy var appleLoginButton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = .black
        button.setImage(UIImage(systemName: "apple.logo"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitle("Apple로 로그인", for: .normal)
        button.setTitleColor(UIColor(hex: "ffffff"), for: .normal)
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.imageView?.tintColor = .white
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(appleLoginClicked), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(hex: "FFFFFF")
//        self.configureNavBar()
        self.configureLabel()
        self.configureButton()
        self.configureImage()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden = true
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = true
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.navigationController?.navigationBar.isHidden = true
//    }
    //
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        self.navigationController?.navigationBar.isHidden = false
    //    }
    
    //    private func configureNavBar() {
    //        self.navigationController?.navigationBar.topItem?.title = ""
    //        self.navigationController?.navigationBar.tintColor = .gray
    //    }
    
    private func configureLabel() {
        self.view.addSubview(mogakLabel)
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(48)
            $0.centerX.equalToSuperview()
        })
        
    }
    
    private func configureImage() {
        self.view.addSubview(loginImage)
        
        loginImage.snp.makeConstraints({
            $0.top.equalTo(self.mogakLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(6)
            //            $0.bottom.equalTo(self.appleLoginButton.snp.top).offset(-129)
            $0.height.equalToSuperview().multipliedBy(0.53)
        })
    }
    
    private func configureButton() {
        self.view.addSubviews(appleLoginButton)
        
        appleLoginButton.snp.makeConstraints({
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalToSuperview().multipliedBy(0.057)
        })
    }

    @objc private func appleLoginClicked() {
        AppleLoginManage.shared.startSignInWithAppleFlow()
        registerUserInfo.$loginState.sink { isLogined in
            if isLogined {
                print(#fileID, #function, #line, "- isLogined🔥: \(isLogined)")
                let isFirstTime = UserDefaults.standard.bool(forKey: "isFirstTime")
                print(#fileID, #function, #line, "- isFirstTime: \(isFirstTime)")
                let tabBarController = TabBarViewController()

                self.view.window?.rootViewController = tabBarController

//                if isFirstTime {
//                    let termAgreeNavigationVC = TermsAgreeViewController()
//                    let navigationController = UINavigationController(rootViewController: termAgreeNavigationVC)
//                    self.view.window?.rootViewController = navigationController
//                } else {
//                    let tabBarController = TabBarViewController()
//
//                    self.view.window?.rootViewController = tabBarController
//
//                }
                
            } else {
                print(#fileID, #function, #line, "- 로그인 완료 안됨: \(isLogined)")
            }
        }
        .store(in: &cancellables)
    }
}
