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

    private lazy var appleLoginButton = makeLoginButton(title: "Apple로 로그인", image: UIImage(systemName: "apple.logo"), backgroundColor: .black, titleColor: .white).then {
        $0.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
    }

    private lazy var kakaoLoginButton = makeLoginButton(title: "카카오로 로그인", image: UIImage(systemName: "message.fill"), backgroundColor: UIColor(hex: "FEE500"), titleColor: UIColor(hex: "191919")).then {
        $0.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
    }

    private lazy var googleLoginButton = makeLoginButton(title: "Google로 로그인", image: UIImage(named: "GoogleLogo"), backgroundColor: .white, titleColor: UIColor(hex: "191919"), borderColor: UIColor(hex: "DADCE0")).then {
        $0.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
    }

    private lazy var guestLoginButton = makeLoginButton(title: "로그인 없이 계속하기", image: UIImage(systemName: "person.fill"), backgroundColor: DesignSystemColor.white.value, titleColor: DesignSystemColor.black.value, borderColor: DesignSystemColor.black.value).then {
        $0.addTarget(self, action: #selector(guestLoginButtonTapped), for: .touchUpInside)
    }

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

        guard state.isLoginFailed, presentedViewController == nil else { return }
        coordinator?.presentLoginFailure(from: self) { [weak self] in self?.viewModel.clearError() }
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

    /// 아이콘과 글자를 가운데에 모으고 사이를 10pt 띄운다. 아이콘은 모두 18pt.
    private func makeLoginButton(title: String, image: UIImage?, backgroundColor: UIColor, titleColor: UIColor, borderColor: UIColor? = nil) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = image
        configuration.imagePadding = 10
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: UIFont.pretendard(.medium, size: 18)]))
        configuration.baseForegroundColor = titleColor
        configuration.background.backgroundColor = backgroundColor
        configuration.background.cornerRadius = 10
        configuration.background.strokeColor = borderColor
        configuration.background.strokeWidth = borderColor == nil ? 0 : 1
        return UIButton(configuration: configuration)
    }
}
