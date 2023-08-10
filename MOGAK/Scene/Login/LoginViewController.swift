//
//  LoginViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/08.
//

import UIKit
import SnapKit
import AuthenticationServices

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
    
    private lazy var appleLoginButton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 25
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "applelogo"), for: .normal)
        button.setTitle("  Sign in with Apple", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.pretendard(.bold, size: 17)
        button.imageView?.tintColor = .black
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(appleLoginClicked), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "f9f9f9")
        self.configureNavBar()
        self.configureLabel()
        self.configureButton()
        
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
    
    private func configureButton() {
        self.view.addSubviews(appleLoginButton)
        
        appleLoginButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(61)
            $0.top.equalTo(self.subLabel.snp.bottom).offset(328)
            $0.height.equalTo(50)
        })
    }
    
    @objc private func appleLoginClicked() {
        let termVC = TermsAgreeViewController()
        self.navigationController?.pushViewController(termVC, animated: true)
        //        let appleIDProvider = ASAuthorizationAppleIDProvider()
        //        let request = appleIDProvider.createRequest()
        //        request.requestedScopes = [.fullName, .email] //유저로 부터 알 수 있는 정보들(name, email)
        //
        //        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        //        authorizationController.delegate = self
        //        authorizationController.presentationContextProvider = self
        //        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //로그인 성공
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // You can create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
            }
            
            print("useridentifier: \(userIdentifier)")
            //            print("fullName: \(fullName)")
            //            print("email: \(email)")
            
            //Move to NextPage
            let validVC = TermsAgreeViewController()
            validVC.modalPresentationStyle = .fullScreen
            present(validVC, animated: true, completion: nil)
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("username: \(username)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 로그인 실패(유저의 취소도 포함)
        print("login failed - \(error.localizedDescription)")
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
