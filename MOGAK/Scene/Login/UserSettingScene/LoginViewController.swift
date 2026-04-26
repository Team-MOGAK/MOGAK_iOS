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

#if false
// Legacy MOGAK1 login/user-setting implementation (inactive after 1:1 migration to MOGAK2 MG_Presentation).

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
    
    private lazy var guestLoginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = DesignSystemColor.white.value
        button.setTitle("로그인 없이 계속하기", for: .normal)
        button.setTitleColor(UIColor(hex: "000000"), for: .normal)
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.imageView?.tintColor = .white
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(guestLoginClicked), for: .touchUpInside)
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
        self.view.addSubviews(appleLoginButton, guestLoginButton)
        
        appleLoginButton.snp.makeConstraints({
            $0.bottom.equalTo(self.guestLoginButton.snp.top).offset(-26)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalToSuperview().multipliedBy(0.057)
        })
        
        guestLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalToSuperview().multipliedBy(0.057)
        }
    }

    @objc private func appleLoginClicked() {
        AppleLoginManage.shared.startSignInWithAppleFlow()
//        registerUserInfo.$loginState.sink { loginState in
//            if let loginState = loginState {
//                if loginState {
//                    if self.registerUserInfo.userIsRegistered {
//                        let tabBarController = TabBarViewController()
//                        self.view.window?.rootViewController = tabBarController
//                    } else {
//                        let termAgreeNavigationVC = TermsAgreeViewController()
//                        let navigationController = UINavigationController(rootViewController: termAgreeNavigationVC)
//                        self.view.window?.rootViewController = navigationController
//                    }
//                }else {
//                    print(#fileID, #function, #line, "- 로그인 완료 안됨: \(loginState)")
//                    let loginViewController = LoginViewController()
//                    self.present(loginViewController, animated: false)
////                    self.view.window?.rootViewController = loginViewController
//                }
//            }
//        }
//        .store(in: &cancellables)
    }
    
    @objc private func guestLoginClicked() {
        
        RegisterUserInfo.shared.loginState = .guest
    }
}


#if DEBUG
import SwiftUI
struct Preview8: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        LoginViewController()
    }
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct LoginViewController_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            Preview8()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
        }
    }
}
#endif

