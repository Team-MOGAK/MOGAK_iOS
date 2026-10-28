//
//  MG2NicknameViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import SnapKit
import Then
import UIKit

final class MG2NicknameViewController: UIViewController {
    private let viewModel: MG2NicknameViewModel
    weak var coordinator: MG2LoginCoordinator?

    init(viewModel: MG2NicknameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headerView = MG2ScreenHeaderView(title: viewModel.isEditing ? "닉네임 변경" : "프로필 설정", subtitle: "어떤 이름으로 모각러들과 만나 볼까요?")

    private let profileImageView = MG2ProfileImageView()

    private let nicknameLabel = MG2FieldLabel("닉네임")

    private lazy var nicknameTextField: MG2TextField = {
        let textField = MG2TextField()
        textField.placeholder = viewModel.currentNickname.isEmpty ? "닉네임을 적어 주세요" : viewModel.currentNickname
        textField.delegate = self
        textField.returnKeyType = .done
        textField.accessibilityLabel = "닉네임"
        return textField
    }()

    private let guideLabel: MG2HintLabel = {
        let label = MG2HintLabel()
        label.show("최대 10자까지 적을 수 있어요")
        return label
    }()

    private lazy var nextButton: UIButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle(viewModel.isEditing ? "닉네임 저장" : "다음", for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface
        configureNavigationBar()
        configureLabel()
        configureProfileImage()
        configureTextField()
        configureButton()
        renderProfileImage()
        renderSubmissionState()
    }

    private func configureNavigationBar() {
        applyStepNavigationBar()
    }

    private func configureLabel() {
        view.addSubview(headerView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(DS.Space.sheet)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
    }

    private func configureProfileImage() {
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            // 가입 완료 아바타 120.
            $0.width.height.equalTo(120)
            $0.top.equalTo(headerView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        // 프로필 수정에서는 "프로필 이미지 변경" 화면에서 바꾼다.
        profileImageView.isEditable = !viewModel.isEditing
        profileImageView.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
    }

    private func configureTextField() {
        view.addSubviews(nicknameLabel, nicknameTextField, guideLabel)

        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
    }

    private func configureButton() {
        view.addSubview(nextButton)

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(DS.Size.button)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16)
        }
    }

    // MARK: - objc

    @objc private func profileImageTapped() {
        coordinator?.presentProfileImageSelection(imageIDs: viewModel.profileImageIDs, selectedIndex: viewModel.selectedProfileImageIndex, onSelection: { [weak self] index in
            self?.viewModel.selectProfileImage(at: index)
            self?.renderProfileImage()
            self?.renderSubmissionState()
        }, from: self)
    }

    @objc private func nextButtonTapped() {
        let nickname = nicknameTextField.text ?? ""
        guard viewModel.canSubmit(nickname) else { return }
        showLoading()
        viewModel.submit(nickname) { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success(.continueRegistration(let draft)):
                coordinator?.routeToChooseJob(draft: draft, from: self)
            case .success(.profileUpdated):
                coordinator?.routeBack(from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func renderProfileImage() {
        profileImageView.image = UIImage(named: MG2ProfileImage.assetName(for: viewModel.selectedProfileImageID))
    }

    private func renderSubmissionState() {
        nextButton.isEnabled = viewModel.canSubmit(nicknameTextField.text ?? "")
    }
}

extension MG2NicknameViewController: UITextFieldDelegate {
    //외부 탭시 키보드 내림.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    // 리턴 키 입력 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        nicknameTextField.isInvalid = false
        guideLabel.show("최대 10자까지 적을 수 있어요")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let validationMessage = viewModel.isEditing && text.isEmpty ? nil : viewModel.nicknameValidationMessage(text)
        renderSubmissionState()
        nicknameTextField.isInvalid = validationMessage != nil
        if let validationMessage {
            guideLabel.show(validationMessage, state: .bad)
        } else {
            // 중복 여부는 제출할 때 서버가 알려 주므로 여기서는 통과(초록)로 보이지 않는다.
            guideLabel.show("최대 10자까지 적을 수 있어요")
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        return currentText.replacingCharacters(in: textRange, with: string).count
            <= viewModel.nicknameMaximumLength
    }
}
