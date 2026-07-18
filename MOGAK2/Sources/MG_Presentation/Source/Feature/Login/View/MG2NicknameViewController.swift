//
//  NicknameViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import UIKit
import SnapKit
import Then

final class MG2NicknameViewController: UIViewController {
    private let profileViewModel: MG2ProfileSetupViewModel
    private let mode: MG2ProfileSetupMode
    weak var coordinator: MG2LoginCoordinator?

    init(
        mode: MG2ProfileSetupMode = .registration,
        profileViewModel: MG2ProfileSetupViewModel
    ) {
        self.mode = mode
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let setNicknameLabel : UILabel = {
        let label = UILabel()
        label.text = "프로필 설정"
        label.font = UIFont.pretendard(.bold, size: 24)
        label.textColor = .black
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "어떤 이름으로 모각러들과 교류해볼까요?"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = UIColor(hex: "808497")
        return label
    }()
    
    private lazy var setProfile = UIButton().then {
        $0.setImage(UIImage(named: "setProfile"), for: .normal)
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(settingProfileImage), for: .touchUpInside)
    }
    
    private lazy var editProfileIcon = UIImageView().then {
        $0.image = UIImage(named: "editIcon")
    }
    
    private lazy var deleteImageButton = UIButton().then {
        $0.setImage(UIImage(named: "deleteIcon"), for: .normal)
        $0.addTarget(self, action: #selector(deleteProfileImage), for: .touchUpInside)
    }
    
    private lazy var nicknameTextField : UITextField = {
        let textField = UITextField()
        let placeholderAttributes = [NSAttributedString.Key.font: UIFont.pretendard(.medium, size: 16), NSAttributedString.Key.foregroundColor : UIColor(hex: "BFC3D4")]
        let placeholderText = profileViewModel.nickname.isEmpty ? "닉네임을 입력해주세요." : profileViewModel.nickname
        textField.textAlignment = .left
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 0.0))
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "EEF0F8")
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        return textField
    }()
    
    private let tfSubLabel : UILabel = {
        let label = UILabel()
        label.text = "최대 10자까지 입력할 수 있습니다."
        label.font = UIFont.pretendard(.medium, size: 14)
        label.textColor = UIColor(hex: "808497")
        return label
    }()
    
    
    private lazy var nextButton: UIButton = {
        let button = MG2PrimaryActionButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(nextButtonIsClicked), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureLabel()
        self.configureSetProfile()
        self.configureTextField()
        self.configureButton()
        self.configureDeleteButton()
        renderProfileImage()
        renderSubmissionState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setProfile.layer.cornerRadius = setProfile.frame.height / 2
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        [setNicknameLabel, subLabel].forEach({view.addSubview($0)})
        
        setNicknameLabel.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(setNicknameLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
    }
    
    private func configureSetProfile() {
        self.view.addSubviews(setProfile, editProfileIcon)
        setProfile.snp.makeConstraints({
            $0.width.height.equalTo(100)
            $0.top.equalTo(self.subLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        })
        
        editProfileIcon.snp.makeConstraints { make in
            make.trailing.equalTo(setProfile.snp.trailing)
            make.bottom.equalTo(setProfile.snp.bottom)
        }
    }
    
    private func configureTextField() {
        [nicknameTextField, tfSubLabel].forEach({view.addSubview($0)})
        
        nicknameTextField.snp.makeConstraints({
            $0.top.equalTo(self.setProfile.snp.bottom).offset(52)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.061)
        })
        
        tfSubLabel.snp.makeConstraints({
            $0.top.equalTo(self.nicknameTextField.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
    }
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            //            $0.height.equalTo(53)
            $0.height.equalToSuperview().multipliedBy(0.06)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        })
    }
    
    private func configureDeleteButton() {
        self.view.addSubview(deleteImageButton)
        deleteImageButton.snp.makeConstraints { make in
            make.top.equalTo(self.setProfile.snp.top)
            make.leading.equalTo(self.setProfile.snp.leading)
        }
    }
    
    
    // MARK: - objc
    
    @objc private func settingProfileImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func deleteProfileImage() {
        let defaultImageData = UIImage(named: "setProfile")?.jpegData(compressionQuality: 1.0)
        profileViewModel.updateProfileImageData(
            mode == .editing ? defaultImageData : nil,
            mode: mode
        )
        renderProfileImage()
        renderSubmissionState()
    }
    
    @objc private func nextButtonIsClicked() {
        let nickname = nicknameTextField.text ?? ""
        showLoading()
        profileViewModel.submitNickname(
            nickname,
            mode: mode
        ) { [weak self] result in
            guard let self else { return }
            hideLoading()
            switch result {
            case .success(.registrationVerified):
                coordinator?.routeToChooseJob(from: self)
            case .success(.profileUpdated):
                coordinator?.routeBack(from: self)
            case .failure(let error):
                coordinator?.presentError(error, from: self)
            }
        }
    }

    private func renderProfileImage() {
        if let imageData = profileViewModel.profileImageData,
           let image = UIImage(data: imageData) {
            setProfile.setImage(image, for: .normal)
            deleteImageButton.isHidden = false
        } else {
            setProfile.setImage(UIImage(named: "setProfile"), for: .normal)
            deleteImageButton.isHidden = true
        }
    }

    private func renderSubmissionState() {
        let isEnabled = profileViewModel.canSubmitNickname(
            nicknameTextField.text ?? "",
            mode: mode
        )
        nextButton.isEnabled = isEnabled
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
        tfSubLabel.text = "최대 10글자까지 입력가능합니다."
        tfSubLabel.textColor = UIColor(hex: "808497")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let validationMessage = mode == .editing && text.isEmpty
            ? nil
            : profileViewModel.nicknameValidationMessage(text)
        renderSubmissionState()
        tfSubLabel.text = validationMessage ?? "최대 10글자까지 입력가능합니다."
        tfSubLabel.textColor = validationMessage == nil
            ? UIColor(hex: "808497")
            : UIColor(hex: "FF2323")
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        return currentText.replacingCharacters(in: textRange, with: string).count
            <= profileViewModel.nicknameMaximumLength
    }
    
    
}

extension MG2NicknameViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileViewModel.updateProfileImageData(
                image.jpegData(compressionQuality: 1.0),
                mode: mode
            )
            renderProfileImage()
            renderSubmissionState()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
