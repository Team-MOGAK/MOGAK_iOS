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
        label.attributedText = NSAttributedString(string: "모두가 각자의 성장을\n응원하는 여정,\n시작해 볼까요?", attributes: T.onboardingTitle.attributes(alignment: .center))
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityTraits = .header
        return label
    }()

    /// 일러스트(384×448)는 남는 자리만 쓴다. 작은 화면(SE)에서는 문구 · 버튼보다 먼저 줄어든다.
    private let loginImage = UIImageView().then {
        $0.image = UIImage(named: "LoginLogo")
        $0.contentMode = .scaleAspectFit
        $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
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

    private lazy var guestLoginButton = MG2PrimaryActionButton(style: .ghost).then {
        $0.setTitle("로그인 없이 둘러보기", for: .normal)
        $0.accessibilityHint = "둘러보기에서는 기록이 남지 않아요"
        $0.addTarget(self, action: #selector(guestLoginButtonTapped), for: .touchUpInside)
    }

    private let guestHintLabel = UILabel().then {
        $0.apply(.footnote, color: DS.Color.muted)
        $0.text = "둘러보기에서는 기록이 남지 않아요"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.isAccessibilityElement = false
    }

    private lazy var loginButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [appleLoginButton, kakaoLoginButton, googleLoginButton, guestLoginButton, guestHintLabel])
        stackView.axis = .vertical
        stackView.spacing = DS.Space.stack
        stackView.setCustomSpacing(4, after: googleLoginButton)
        stackView.setCustomSpacing(0, after: guestLoginButton)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = DS.Color.surface
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
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
    }

    private func configureImage() {
        view.addSubview(loginImage)

        loginImage.snp.makeConstraints {
            $0.top.equalTo(mogakLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
            $0.bottom.equalTo(loginButtonStackView.snp.top).offset(-20)
        }
    }

    private func configureButton() {
        view.addSubview(loginButtonStackView)

        loginButtonStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.gutter)
        }
        [appleLoginButton, kakaoLoginButton, googleLoginButton].forEach { button in button.snp.makeConstraints { $0.height.equalTo(DS.Size.button) } }
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

    /// 소셜 로그인 버튼은 각 회사 브랜드 색을 지키고, 크기 · 모서리 · 글자만 디자인 시스템(primary 52 · 16 · button)에 맞춘다.
    private func makeLoginButton(title: String, image: UIImage?, backgroundColor: UIColor, titleColor: UIColor, borderColor: UIColor? = nil) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = image
        configuration.imagePadding = 10
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        configuration.title = title
        // 글자 크기를 바꿔도 다시 맞춘다. 제목은 한 줄, 넘치면 0.8배까지 줄인 뒤 말줄임.
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = T.button.font
            return attributes
        }
        configuration.titleLineBreakMode = .byTruncatingTail
        configuration.baseForegroundColor = titleColor
        configuration.background.backgroundColor = backgroundColor
        configuration.background.cornerRadius = DS.Radius.button
        configuration.background.strokeColor = borderColor
        configuration.background.strokeWidth = borderColor == nil ? 0 : 1
        let button = UIButton(configuration: configuration)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.enablePressFeedback()
        return button
    }
}
