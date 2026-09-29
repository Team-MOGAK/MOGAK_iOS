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

    private let setNicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 설정"
        label.font = UIFont.pretendard(.bold, size: 24)
        label.textColor = .black
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 이름으로 모각러들과 교류해볼까요?"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = DesignSystemColor.gray4.value
        return label
    }()

    private let profileImageView = MG2ProfileImageView()

    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        let placeholderAttributes = [NSAttributedString.Key.font: UIFont.pretendard(.medium, size: 16), NSAttributedString.Key.foregroundColor : DesignSystemColor.gray3.value]
        let placeholderText = viewModel.currentNickname.isEmpty ? "닉네임을 입력해주세요." : viewModel.currentNickname
        textField.textAlignment = .left
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 0.0))
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.backgroundColor = DesignSystemColor.gray2.value
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        return textField
    }()

    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "최대 10자까지 입력할 수 있습니다."
        label.font = UIFont.pretendard(.medium, size: 14)
        label.textColor = DesignSystemColor.gray4.value
        return label
    }()

    private lazy var nextButton: UIButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textAlignment = .center
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
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = .white
        configureNavigationBar()
        configureLabel()
        configureProfileImage()
        configureTextField()
        configureButton()
        renderProfileImage()
        renderSubmissionState()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = .gray
    }

    private func configureLabel() {
        [setNicknameLabel, subLabel].forEach({view.addSubview($0)})

        setNicknameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        subLabel.snp.makeConstraints {
            $0.top.equalTo(setNicknameLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
    }

    private func configureProfileImage() {
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.top.equalTo(subLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        }
        // 프로필 수정에서는 "프로필 이미지 변경" 화면에서 바꾼다.
        profileImageView.isEditable = !viewModel.isEditing
        profileImageView.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
    }

    private func configureTextField() {
        [nicknameTextField, guideLabel].forEach({view.addSubview($0)})

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(52)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.061)
        }

        guideLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
    }

    private func configureButton() {
        view.addSubview(nextButton)

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            //            $0.height.equalTo(53)
            $0.height.equalToSuperview().multipliedBy(0.06)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
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
        guideLabel.text = "최대 10글자까지 입력가능합니다."
        guideLabel.textColor = DesignSystemColor.gray4.value
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let validationMessage = viewModel.isEditing && text.isEmpty ? nil : viewModel.nicknameValidationMessage(text)
        renderSubmissionState()
        guideLabel.text = validationMessage ?? "최대 10글자까지 입력가능합니다."
        guideLabel.textColor = validationMessage == nil ? DesignSystemColor.gray4.value : DesignSystemColor.red.value
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        return currentText.replacingCharacters(in: textRange, with: string).count
            <= viewModel.nicknameMaximumLength
    }
}
