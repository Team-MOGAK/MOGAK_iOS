//
//  MG2LoginViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/08.
//

import UIKit
import SnapKit
import Then

final class MG2LoginViewController: UIViewController {
    weak var coordinator: MG2LoginCoordinator?
    var onAuthenticationCompleted: (() -> Void)?
    var onGuestContinue: (() -> Void)?

    private let viewModel: MG2LoginViewModel
    init(viewModel: MG2LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let mogakLabel: UILabel = {
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
        let button = makeSocialLoginButton(title: "Apple로 로그인", backgroundColor: .black, titleColor: .white, image: UIImage(systemName: "apple.logo"), imageTintColor: .white)
        button.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var kakaoLoginButton: UIButton = {
        let button = makeSocialLoginButton(title: "카카오로 로그인", backgroundColor: UIColor(hex: "FEE500"), titleColor: UIColor(hex: "191919"), image: UIImage(systemName: "message.fill"), imageTintColor: UIColor(hex: "191919"))
        button.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var googleLoginButton: UIButton = {
        let button = makeSocialLoginButton(title: "G  Google로 로그인", backgroundColor: .white, titleColor: UIColor(hex: "191919"), image: nil, imageTintColor: nil, borderColor: UIColor(hex: "DADCE0"))
        button.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var guestLoginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = DesignSystemColor.white.value
        button.setTitle("로그인 없이 계속하기", for: .normal)
        button.setTitleColor(DesignSystemColor.black.value, for: .normal)
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(guestLoginButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loginButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [appleLoginButton, kakaoLoginButton, googleLoginButton, guestLoginButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = DesignSystemColor.white.value
        configureLabel()
        configureButton()
        configureImage()
        bindViewModel()
        render(viewModel.state)
    }

    private func configureLabel() {
        view.addSubview(mogakLabel)

        mogakLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            $0.centerX.equalToSuperview()
        }
    }

    private func configureImage() {
        view.addSubview(loginImage)

        loginImage.snp.makeConstraints {
            $0.top.equalTo(mogakLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(6)
            $0.bottom.equalTo(loginButtonStackView.snp.top).offset(-20)
        }
    }

    private func configureButton() {
        view.addSubview(loginButtonStackView)

        loginButtonStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(220)
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in self?.render(state) }
    }

    private func render(_ state: MG2LoginViewState) {
        let buttons = [appleLoginButton, kakaoLoginButton, googleLoginButton, guestLoginButton]
        buttons.forEach {
            $0.isEnabled = !state.isLoading
            $0.alpha = state.isLoading ? 0.6 : 1
        }
        state.isLoading ? showLoading() : hideLoading()

        guard let errorMessage = state.errorMessage, presentedViewController == nil else { return }
        coordinator?.presentLoginError(errorMessage, from: self) { [weak self] in self?.viewModel.clearError() }
    }

    @objc private func appleLoginButtonTapped() {
        login(with: .apple)
    }

    @objc private func kakaoLoginButtonTapped() {
        login(with: .kakao)
    }

    @objc private func googleLoginButtonTapped() {
        login(with: .google)
    }

    private func login(with provider: MG2SocialLoginProvider) {
        viewModel.login(provider: provider) { [weak self] in self?.onAuthenticationCompleted?() }
    }

    @objc private func guestLoginButtonTapped() {
        viewModel.continueAsGuest()
        onGuestContinue?()
    }

    private func makeSocialLoginButton(title: String, backgroundColor: UIColor, titleColor: UIColor, image: UIImage?, imageTintColor: UIColor?, borderColor: UIColor? = nil) -> UIButton {
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
