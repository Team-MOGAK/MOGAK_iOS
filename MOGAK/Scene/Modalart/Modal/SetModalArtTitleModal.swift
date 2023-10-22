//
//  SetModalArtTitleModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/22.
//

import Foundation
import UIKit
import SnapKit

class SetModalArtTitleModal: UIView {
    var vc: CustomBottomModalSheet!
    
    let titleColorPalette: [UIColor] = [DesignSystemColor.gray.value, DesignSystemColor.red.value, DesignSystemColor.black.value, DesignSystemColor.green.value, DesignSystemColor.lightGreen.value, DesignSystemColor.orange.value, DesignSystemColor.pink.value, DesignSystemColor.purple.value, DesignSystemColor.signature.value]
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 3
        
        return view
    }()
    
    var title: UILabel = {
        let label = UILabel()
        label.text = "나의 가장 큰 목표는?"
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()
    
    var titleSetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이루고픈 목표를 입력해 주세요."
        textField.setPlaceholderColor(DesignSystemColor.gray3.value)
        textField.textColor = .black
        textField.autocorrectionType = .no
        return textField
    }()
    
    var colorStackView: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 16
        stk.distribution = .fillEqually
        return stk
    }()
    
    var colorScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("취소", for: .normal)
        btn.backgroundColor = DesignSystemColor.gray2.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.black.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()

    var completeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("완료", for: .normal)
        btn.backgroundColor = DesignSystemColor.gray3.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()
    
    var btnStackView: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 10
        stk.distribution = .fillEqually
        return stk
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = DesignSystemColor.white.value
        titleSetTextField.delegate = self
        
        self.configureLayout()
        self.mainModalArtTitleColors()
        
        self.cancelBtn.addTarget(vc, action: #selector(cancelBtnTapped(_:)), for: .touchUpInside)
        self.completeBtn.addTarget(vc, action: #selector(completeBtnTapped(_:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    //MARK: - color palette만들기
    private func mainModalArtTitleColors() {
        titleColorPalette.map { color in
            let view: UIView = {
                let view = UIView()
                view.backgroundColor = color
                view.layer.cornerRadius = 20 //width가 40이니까 그거의 절반인 20으로만들기
                view.clipsToBounds = true
                view.snp.makeConstraints { make in
                    make.size.equalTo(40)
                }
                return view
            }()
            return view
        }
        .forEach(colorStackView.addArrangedSubview)
    }
    
    @objc func cancelBtnTapped(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 취소버튼 클릭")
        vc.dismiss(animated: true)
    }
    
    @objc func completeBtnTapped(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 완료버튼 클릭")
        vc.dismiss(animated: true)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        guard let screenSize = vc.view.window?.windowScene?.screen.bounds else { return }
        let bottomPadding: CGFloat = vc.view.safeAreaInsets.bottom
        self.frame.origin.y = screenSize.height - (keyboardSize.height + vc.bottomHeight + bottomPadding)
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        guard let screenSize = vc.view.window?.windowScene?.screen.bounds else { return }
        let bottomPadding: CGFloat = vc.view.safeAreaInsets.bottom
        self.frame.origin.y = screenSize.height - (vc.bottomHeight + bottomPadding + 10)
        
    }
}

//MARK: - 오토레이아웃 잡기
extension SetModalArtTitleModal {
    private func configureLayout() {
        self.addSubviews(title, titleSetTextField, colorScrollView, btnStackView, indicatorView)
        self.colorScrollView.addSubview(colorStackView)
        self.btnStackView.addArrangedSubview(cancelBtn)
        self.btnStackView.addArrangedSubview(completeBtn)
        
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        titleSetTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(title.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        colorScrollView.snp.makeConstraints { make in
            make.top.equalTo(titleSetTextField.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        colorStackView.snp.makeConstraints { make in
            make.top.equalTo(colorScrollView.snp.top)
            make.leading.equalTo(colorScrollView.snp.leading)
            make.bottom.equalTo(colorScrollView.snp.bottom)
            make.trailing.equalTo(colorScrollView.snp.trailing)
        }
        
        btnStackView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleSetTextField.snp.bottom).offset(99)
            make.leading.equalToSuperview().offset(20)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(100)
            make.height.equalTo(5)
        }
    }
}

extension SetModalArtTitleModal: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(#fileID, #function, #line, "- 변경된거 탄🐿️")
        let currentText = textField.text ?? ""
        
        guard let stringLength = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringLength, with: string)
        
        return updatedText.count <= 8
    }
}
