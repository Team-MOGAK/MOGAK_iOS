//
//  NicknameViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/11.
//

import UIKit
import SnapKit

class NicknameViewController: UIViewController {
    
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAK"
        label.font = UIFont.pretendard(.medium, size: 15)
        return label
    }()
    
    private let setNicknameLabel : UILabel = {
        let label = UILabel()
        label.text = "닉네임설정"
        label.font = UIFont.pretendard(.medium, size: 15)
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "어떤 이름으로 모각러들과 교류해볼까요?"
        label.font = UIFont.pretendard(.medium, size: 15)
        return label
    }()
    
    private lazy var nicknameTextField : UITextField = {
        let textField = UITextField()
        let placeholderAttributes = [NSAttributedString.Key.font: UIFont.pretendard(.medium, size: 15), NSAttributedString.Key.foregroundColor : UIColor.gray]
        let placeholderText = "닉네임 입력"
        textField.textAlignment = .left
        textField.delegate = self
        //        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        //        textField.leftViewMode = .unlessEditing
        textField.borderStyle = .none
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        return textField
    }()
    
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(nextButtonIsClicked), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureLabel()
        self.configureTextField()
        self.configureButton()
    }
    
    override func viewDidLayoutSubviews() {
        self.configureBorder()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubviews(mogakLabel, setNicknameLabel, subLabel)
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            $0.leading.equalToSuperview().offset(20)
        })
        
        setNicknameLabel.snp.makeConstraints({
            $0.top.equalTo(mogakLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(setNicknameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        })
    }
    
    private func configureTextField() {
        self.view.addSubview(nicknameTextField)
        
        nicknameTextField.snp.makeConstraints({
            $0.top.equalTo(subLabel.snp.bottom).offset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(33)
        })
    }
    
    private func configureBorder() {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: nicknameTextField.frame.height-1, width: nicknameTextField.frame.width, height: 1)
        border.backgroundColor = UIColor.black.cgColor
        nicknameTextField.layer.addSublayer((border))
    }
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(53)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-53)
        })
    }
    
    @objc private func nextButtonIsClicked() {
        // tf가 공백 또는 nil이라면 경고, 아니라면 다음 페이지
        if let text = nicknameTextField.text {
            if text == "" {
                let alert = UIAlertController(title: "경고", message: "nickname 입력 바람.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "다시 돌아가기", style: .cancel))
                present(alert, animated: true)
            }
            print("text: \(text)")
            let chooseJobVC = ChooseJobViewController()
            self.navigationController?.pushViewController(chooseJobVC, animated: true)
        } else {
            let alert = UIAlertController(title: "경고", message: "nickname 입력 바람.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "다시 돌아가기", style: .cancel))
            present(alert, animated: true)
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
    // 글자수 제한 디폴트 10 + 지우기(백스페이스) 가능 + 문자,숫자,특수문자 조합
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()_+")
        let allowedCharacterSet = CharacterSet(charactersIn: string)
        let isValid = allowedCharacterSet.isSubset(of: allowedCharacters)
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        return isValid && newLength <= 10
    }
    
}
