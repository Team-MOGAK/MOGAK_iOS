//
//  LoginViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/08.
//

import UIKit
import SnapKit
import AuthenticationServices
import Combine

class MG2LoginViewController: UIViewController {
    
    let registerUserInfo = MG2Deps.app.userState
    private let viewModel: MG2LoginViewModel
    weak var coordinator: MG2LoginCoordinator?
    var cancellables = Set<AnyCancellable>()

    init(viewModel: MG2LoginViewModel = DIContainer.shared.resolveRequired(MG2LoginViewModel.self)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private lazy var appleLoginButton: UIButton = {
        let button = makeSocialLoginButton(
            title: "Apple로 로그인",
            backgroundColor: .black,
            titleColor: .white,
            image: UIImage(systemName: "apple.logo"),
            imageTintColor: .white
        )
        button.addTarget(self, action: #selector(appleLoginClicked), for: .touchUpInside)
        return button
    }()

    private lazy var kakaoLoginButton: UIButton = {
        let button = makeSocialLoginButton(
            title: "카카오로 로그인",
            backgroundColor: UIColor(hex: "FEE500"),
            titleColor: UIColor(hex: "191919"),
            image: UIImage(systemName: "message.fill"),
            imageTintColor: UIColor(hex: "191919")
        )
        button.addTarget(self, action: #selector(kakaoLoginClicked), for: .touchUpInside)
        return button
    }()

    private lazy var googleLoginButton: UIButton = {
        let button = makeSocialLoginButton(
            title: "G  Google로 로그인",
            backgroundColor: .white,
            titleColor: UIColor(hex: "191919"),
            image: nil,
            imageTintColor: nil,
            borderColor: UIColor(hex: "DADCE0")
        )
        button.addTarget(self, action: #selector(googleLoginClicked), for: .touchUpInside)
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

    private lazy var loginButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            appleLoginButton,
            kakaoLoginButton,
            googleLoginButton,
            guestLoginButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
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
            $0.bottom.equalTo(self.loginButtonStackView.snp.top).offset(-20)
        })
    }
    
    private func configureButton() {
        self.view.addSubview(loginButtonStackView)

        loginButtonStackView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(220)
        }
    }

    @objc private func appleLoginClicked() {
        viewModel.startAppleLogin()
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
//                    let loginViewController = MG2LoginViewController()
//                    self.present(loginViewController, animated: false)
////                    self.view.window?.rootViewController = loginViewController
//                }
//            }
//        }
//        .store(in: &cancellables)
    }

    @objc private func kakaoLoginClicked() {
        viewModel.startKakaoLogin()
    }

    @objc private func googleLoginClicked() {
        viewModel.startGoogleLogin()
    }
    
    @objc private func guestLoginClicked() {
        viewModel.continueAsGuest()
    }

    private func makeSocialLoginButton(title: String,
                                       backgroundColor: UIColor,
                                       titleColor: UIColor,
                                       image: UIImage?,
                                       imageTintColor: UIColor?,
                                       borderColor: UIColor? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.setImage(image, for: .normal)
        button.tintColor = imageTintColor ?? titleColor
        button.semanticContentAttribute = .forceLeftToRight
        if let borderColor {
            button.layer.borderWidth = 1
            button.layer.borderColor = borderColor.cgColor
        }
        return button
    }
}
