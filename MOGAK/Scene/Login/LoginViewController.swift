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

class LoginViewController: UIViewController {
    
    let registerUserInfo = RegisterUserInfo.shared
    
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
        //        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(hex: "FFFFFF")
        //        self.configureNavBar()
        self.configureLabel()
        self.configureButton()
        self.configureImage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        super.viewDidDisappear(animated)
    //        self.navigationController?.navigationBar.isHidden = false
    //    }
    
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
        //                let termVC = TermsAgreeViewController()
        //                self.navigationController?.pushViewController(termVC, animated: true)
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] //유저로 부터 알 수 있는 정보들(name, email)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
            let realFullName = appleIDCredential.fullName?.formatted()
            let email = appleIDCredential.email
            UserDefaults.standard.set(realFullName, forKey: "userName")
            UserDefaults.standard.set(email, forKey: "userEmail")
            registerUserInfo.userEmail = email
            registerUserInfo.userName = realFullName
            print("싱글톤 유저 이메일 \(registerUserInfo.userEmail), 싱글톤 유저 이름 \(registerUserInfo.userName)")
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
            }
            
            // 두번째부터는 여기서 이메일을 받아와야 함
            if let tokenString = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) {
                let email2 = Utils.decode(jwtToken: tokenString)["email"] as? String ?? ""
                print("두번째 이메일 \(email2)")
                
                UserDefaults.standard.set(email2, forKey: "userEmail")
            }
            
            if let email = UserDefaults.standard.string(forKey: "userEmail") {
                login(email: "jdkfj@naver.com")
            }
            //Move to NextPage
            
            //
            //                        present(validVC, animated: true, completion: nil)
            
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

extension LoginViewController {
    func login(email: String) {
        let url = ApiConstants.baseURL + "/api/users/login/\(email)"
        
        let headers: HTTPHeaders = [
            "accept": "application/json"
        ]
        
        AF.request(url, method: .post, headers: headers)
            .response { response in
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    if let authorization = headerFields["Authorization"] {
                        print("Authorization Header: \(authorization)")
                        UserDefaults.standard.set(authorization, forKey: "accessToken")
                        let mainVC = TabBarViewController()
                        mainVC.modalPresentationStyle = .fullScreen
                        self.present(mainVC, animated: true)
                    } else {
                        let validVC = TermsAgreeViewController()
                        validVC.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(validVC, animated: true)
                    }
                    
                    // Print all header fields
                    print("All Headers: \(headerFields)")
                }
                
                if let data = response.data {
                    // Process the data here
                }
            }
        
    }
}
