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

class NicknameViewController: UIViewController {
    
    let registerUserInfo = RegisterUserInfo.shared
    let apiManger = ApiManager.shared
    
    private let setNicknameLabel : UILabel = {
        let label = UILabel()
        label.text = "닉네임설정"
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
    
    private lazy var nicknameTextField : UITextField = {
        let textField = UITextField()
        let placeholderAttributes = [NSAttributedString.Key.font: UIFont.pretendard(.medium, size: 16), NSAttributedString.Key.foregroundColor : UIColor(hex: "BFC3D4")]
        let placeholderText = "닉네임을 입력해주세요."
        textField.textAlignment = .left
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(hex: "EEF0F8")
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        return textField
    }()
    
    private let tfSubLabel : UILabel = {
        let label = UILabel()
        label.text = "문자, 숫자, 특수문자 조합 최대 10자를 적어주세요."
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureLabel()
        self.configureSetProfile()
        self.configureTextField()
        self.configureButton()
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
        self.view.addSubview(setProfile)
        
        setProfile.snp.makeConstraints({
            $0.width.height.equalTo(100)
            $0.top.equalTo(self.subLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        })
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
    
    
    // MARK: - objc
    
    @objc private func settingProfileImage() {
        // 이미지 선택 컨트롤러를 생성합니다.
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func nextButtonIsClicked() {
        // tf가 공백 또는 nil이라면 경고, 아니라면 다음 페이지
        
        if let text = nicknameTextField.text {
            registerUserInfo.nickName = text
            print("저장된 닉네임 - \(registerUserInfo.nickName)")
            validateNickname(nickName: text)
        }
        
        
        //
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
        tfSubLabel.text = "문자, 숫자, 특수문자 조합 최대 10자를 적어주세요."
        tfSubLabel.textColor = UIColor(hex: "808497")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.validateNickname() {
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
            setProfile.setImage(image, for: .normal)
            
            // Kingfisher를 사용하여 이미지를 캐싱하고 표시합니다.
            let options: KingfisherOptionsInfo = [.transition(.fade(0.2))]
            if let imageURL = info[.imageURL] as? URL {
                registerUserInfo.profileImage = imageURL.absoluteString
                print("저장된 이미지 주소 \(registerUserInfo.profileImage)")
                
                // Kingfisher를 사용하여 버튼 이미지를 설정합니다.
                setProfile.kf.setImage(with: imageURL, for: .normal, placeholder: image, options: options, completionHandler: { result in
                    switch result {
                    case .success(_):
                        // 버튼 모양을 원 모양으로 변경합니다.
                        self.setProfile.layer.cornerRadius = self.setProfile.frame.height / 2
                        self.setProfile.clipsToBounds = true
                        break
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
    func validateNickname(nickName: String) {
        
        let url = ApiConstants.BaseURL + "/api/users/\(nickName)/verify"
        
        AF.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ValidateNicknameModel.self) { response in
                switch response.result {
                case .success(let response):
                    if response.status == "OK" {
                        print("성공")
                        let chooseJobVC = ChooseJobViewController()
                        chooseJobVC.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(chooseJobVC, animated: true)
                    }
                case .failure(let error):
                    print("error \(error)")
                }
            }
        //        ApiManager.shared.getData(url: url) { (result: <ValidateNickNameModel>) in
        //            switch result {
        //            case .success:
        //                print("success")
        //            case .failure(.statusCode(let statusCode)):
        //                if statusCode == 409 {
        //                    print("Duplicate User Error: User already exists.")
        //                    self.tfSubLabel.text = "중복된 닉네임입니다."
        //                    self.tfSubLabel.textColor = UIColor(hex: "FF2323")
        //                } else if statusCode == 200 {
        //                    // 페이지 이동
        //                    let chooseJobVC = ChooseJobViewController()
        //                    chooseJobVC.modalPresentationStyle = .fullScreen
        //                    self.navigationController?.pushViewController(chooseJobVC, animated: true)
        //                }
        //            case .failure(.requestFailed):
        //                print("요청 실패")
        //            case .failure(.invalidResponse):
        //                print("이상한 응답")
        //            }
        //        }
    }
}

