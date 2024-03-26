//
//  NicknameViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import UIKit
import SnapKit
import Kingfisher
import Alamofire
import Combine

class NicknameViewController: UIViewController {
    let registerUserInfo = RegisterUserInfo.shared
    let apiManger = ApiManager.shared
    /// 프로필 수정하러 들어올때와 회원가입 시 프로필을 생성할 때를 구분하기 위한 변수 (프로필 수정할때 -> true, 회원가입 시 프로필 입력 -> false)
    var nicknameAndImageChange: Bool = false
    var profileImageChange: Bool = false
    var changeProfileImage: UIImage? = nil
    var cancellables = Set<AnyCancellable>()
    
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
        let placeholderText = RegisterUserInfo.shared.nickName != nil && RegisterUserInfo.shared.nickName != "" ? RegisterUserInfo.shared.nickName ?? "닉네임을 입력해주세요." : "닉네임을 입력해주세요."
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
    
    
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "BFC3D4")
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(nextButtonIsClicked), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.setProfile.layer.cornerRadius = self.setProfile.frame.height / 2
        self.setProfile.clipsToBounds = true
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
        
        // profile 설정한 사진과 연동되도록 설정
        registerUserInfo.$profileImage.sink { image in
            if self.nicknameAndImageChange && self.profileImageChange {
                self.nextButton.isUserInteractionEnabled = true
                self.nextButton.backgroundColor = UIColor(hex: "475FFD")
            }
            
            if image != nil && self.nicknameAndImageChange {
                self.setProfile.setImage(self.registerUserInfo.profileImage, for: .normal)
                self.deleteImageButton.isHidden = false
            } else {
                self.deleteImageButton.isHidden = true
//                self.deleteImageButton.isHidden = false
            }
        }
        .store(in: &cancellables)
    }
    
    override func viewDidLayoutSubviews() {
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
        self.setProfile.layer.cornerRadius = self.setProfile.frame.height / 2
        self.setProfile.clipsToBounds = true
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
//        if registerUserInfo.profileImage != nil {
            deleteImageButton.snp.makeConstraints { make in
                make.top.equalTo(self.setProfile.snp.top)
                make.leading.equalTo(self.setProfile.snp.leading)
            }
//        }
    }
    
    
    // MARK: - objc
    
    @objc private func settingProfileImage() {
        // 이미지 선택 컨트롤러를 생성합니다.
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func deleteProfileImage() {
        self.setProfile.setImage(UIImage(named: "setProfile"), for: .normal)
//        registerUserInfo.profileImage = nil
        changeProfileImage = UIImage(named: "setProfile")
        if nicknameAndImageChange {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = UIColor(hex: "475FFD")
            profileImageChange = true
        }
        deleteImageButton.isHidden = true
        
    }
    
    @objc private func nextButtonIsClicked() {
        print(#fileID, #function, #line, "- nicknameTextField.text⭐️: \(nicknameTextField.text)")
        let nicknameText = nicknameTextField.text ?? ""
        if nicknameText != "" {
            if nicknameAndImageChange {
                nicknameChange(nickname: nicknameText)
                if profileImageChange {
                    profileImageChangeRequest()
                }
            } else {
                validateNickname(nickName: nicknameText)
            }
        } else if nicknameAndImageChange && profileImageChange {
            profileImageChangeRequest()
        }
    }
}

extension NicknameViewController: UITextFieldDelegate {
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

//        if text.validateNickname() {
        if text.count <= 10 {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = UIColor(hex: "475FFD")
        } else {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = UIColor(hex: "BFC3D4")
        }
        
    }
    // 글자수 제한 디폴트 10 + 지우기(백스페이스) 가능
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 백스페이스 처리
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        guard textField.text!.count < 10 else { return false } // 10 글자로 제한
        
        return true
        
    }
    
    
}

extension NicknameViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 이미지 선택이 완료되었을 때 호출되는 메서드입니다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택된 이미지를 가져옵니다.
        if let image = info[.originalImage] as? UIImage {
            // 가져온 이미지를 버튼 이미지로 설정합니다.
//            setProfile.setImage(image, for: .normal)
            
            // Kingfisher를 사용하여 이미지를 캐싱하고 표시합니다.
            let options: KingfisherOptionsInfo = [.transition(.fade(0.2))]
            if let imageURL = info[.imageURL] as? URL {

                // Kingfisher를 사용하여 버튼 이미지를 설정합니다.
                setProfile.kf.setImage(with: imageURL, for: .normal, placeholder: image, options: options, completionHandler: { result in
                    switch result {
                    case .success(_):
                        // 버튼 모양을 원 모양으로 변경합니다.
                        if self.nicknameAndImageChange {
                            self.changeProfileImage = image
                            self.nextButton.isUserInteractionEnabled = true
                            self.nextButton.backgroundColor = UIColor(hex: "475FFD")
                        }
                        else {
                            self.registerUserInfo.profileImage = image
                        }
                        self.profileImageChange = true
                        self.deleteImageButton.isHidden = false
                        
                    case .failure(let error):
                        // 이미지 표시 중에 에러가 발생한 경우 실행되는 코드
                        print("Error setting button image: \(error)")
                    }
                })
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
// 네트워크 코드
extension NicknameViewController {
    //MARK: - 닉네임 타당성 검증 요청
    func validateNickname(nickName: String) {
        LoadingIndicator.showLoading()
        let nicknameRequest = NicknameChangeRequest(nickname: nickName)
        AF.request(UserRouter.nicknameVerify(nickname: nicknameRequest))
            .responseDecodable(of: ValidateNicknameModel.self) { (response: DataResponse<ValidateNicknameModel, AFError>) in
                LoadingIndicator.hideLoading()
                switch response.result {
                case .success(let data):
                    if data.code == "success" {
                        print("성공")
                        self.registerUserInfo.nickName = self.nicknameTextField.text
                        
                        let chooseJobVC = ChooseJobViewController()
                        chooseJobVC.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(chooseJobVC, animated: true)
                    }
                case .failure(let error):
                    print(#fileID, #function, #line, "- error: \(error)")
                    let decoder = JSONDecoder()
                    let decodeData = try? decoder.decode(ChangeErrorResponse.self, from: response.data ?? Data())
                    let nicknameErrorAlertAction = UIAlertAction(title: "확인", style: .default)
                    let nicknameErrorAlert = UIAlertController(title: "닉네임 오류", message: decodeData?.message, preferredStyle: .alert)
                    nicknameErrorAlert.addAction(nicknameErrorAlertAction)
                    self.present(nicknameErrorAlert, animated: true)
                }
            }
    }
    
    //MARK: - 닉네임 변경
    func nicknameChange(nickname: String) {
        LoadingIndicator.showLoading()
        UserNetwork.shared.nicknameChange(nickname) { result in
            LoadingIndicator.hideLoading()
            switch result {
            case .success(let success):
                print(#fileID, #function, #line, "- success: \(success)")
                self.registerUserInfo.nickName = nickname
                if !self.profileImageChange {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let failure):
                if failure as? APIError == APIError.invalidNickname {
                    let nicknameErrorAlertAction = UIAlertAction(title: "확인", style: .default)
                    let nicknameErrorAlert = UIAlertController(title: "닉네임 오류", message: "닉네임 형식이 올바르지 않습니다! \n닉네임 조합을 다시 확인해주세요", preferredStyle: .alert)
                    nicknameErrorAlert.addAction(nicknameErrorAlertAction)
                    self.present(nicknameErrorAlert, animated: true)
                } else if failure as? APIError == APIError.NotExistUser {
                    let nicknameErrorAlertAction = UIAlertAction(title: "확인", style: .default)
                    let nicknameErrorAlert = UIAlertController(title: "닉네임 오류", message: "존재하지 않는 유저입니다! \n모각 오픈채팅으로 문의해주세요", preferredStyle: .alert)
                    nicknameErrorAlert.addAction(nicknameErrorAlertAction)
                    self.present(nicknameErrorAlert, animated: true)
                }
                else {
                    print(#fileID, #function, #line, "- failure: \(failure)")
                    let nicknameErrorAlertAction = UIAlertAction(title: "확인", style: .default)
                    let nicknameErrorAlert = UIAlertController(title: "닉네임 오류", message: "\(failure)", preferredStyle: .alert)
                    nicknameErrorAlert.addAction(nicknameErrorAlertAction)
                    self.present(nicknameErrorAlert, animated: true)
                }
                
            }
        }
//        let nicknameRequest = NicknameChangeRequest(nickname: nickname)
//        let decoder = JSONDecoder()
//        AF.request(UserRouter.nicknameChange(nickname: nicknameRequest), interceptor: CommonLoginManage())
//            .validate(statusCode: 200..<300)
//            .responseDecodable(of: ChangeSuccessResponse.self) { (response: DataResponse<ChangeSuccessResponse, AFError>) in
//                switch response.result {
//                case .failure(let error):
//                    print(#fileID, #function, #line, "- error: \(error)")
//                    if response.response?.statusCode == 409 {
//                        let decodeData = try? decoder.decode(ChangeErrorResponse.self, from: response.data ?? Data())
//                        print(#fileID, #function, #line, "- decodeData: \(decodeData)")
//                        let nicknameErrorAlertAction = UIAlertAction(title: "확인", style: .default)
//                        let nicknameErrorAlert = UIAlertController(title: "닉네임 오류", message: decodeData?.message, preferredStyle: .alert)
//                        nicknameErrorAlert.addAction(nicknameErrorAlertAction)
//                        self.present(nicknameErrorAlert, animated: true)
//                    }
//                case .success(let data):
//                    self.registerUserInfo.nickName = nickname
//                    if !self.profileImageChange {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//            }
    }
    
    //MARK: - 프로필 사진 변경 요청
    func profileImageChangeRequest() {
        LoadingIndicator.showLoading()
        let userNetwork = UserNetwork.shared
        guard let profileImage = changeProfileImage else { return }
        userNetwork.userImageChange(profileImage) { result in
            LoadingIndicator.hideLoading()
            switch result {
            case .success(let success):
                print(#fileID, #function, #line, "- success: \(success)")
                self.registerUserInfo.profileImage = self.changeProfileImage
                self.navigationController?.popViewController(animated: true)
            case .failure(let failure):
                print(#fileID, #function, #line, "- failure: \(failure)")
                let nicknameErrorAlertAction = UIAlertAction(title: "확인", style: .default)
                let nicknameErrorAlert = UIAlertController(title: "이미지 변경실패", message: failure.localizedDescription, preferredStyle: .alert)
                nicknameErrorAlert.addAction(nicknameErrorAlertAction)
                self.present(nicknameErrorAlert, animated: true)
            }
        }
    }
}

