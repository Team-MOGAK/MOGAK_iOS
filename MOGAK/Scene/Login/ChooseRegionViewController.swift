//
//  ChooseRegionViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/13.
//

import UIKit
import SnapKit

class ChooseRegionViewController: UIViewController {
    
    private let region = ["서울특별시","세종특별자치시","대전광역시","광주광역시","대구광역시","부산광역시","울산광역시","경상남도", "경상북도","전라남도","전라북도","충청남도","충청북도","강원도", "제주도", "독도/울릉도"]
    
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAK"
        label.font = UIFont.pretendard(.medium, size: 15)
        return label
    }()
    
    private let regionLabel : UILabel = {
        let label = UILabel()
        label.text = "거주지 선택"
        label.font = UIFont.pretendard(.medium, size: 15)
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "나와 가장 가까운 모각러들과 함께 성장해 보아요"
        label.font = UIFont.pretendard(.medium, size: 15)
        return label
    }()
    
    private let regionTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 3
        textField.tintColor = .black
        textField.font = UIFont.pretendard(.bold, size: 16)
        textField.addLeftPadding()
        textField.addRightImage(image: UIImage(named: "dropdown")!)
        return textField
    }()
    
    private let regionSubLabel : UILabel = {
        let label = UILabel()
        label.text = "현재는 00도까지만 선택 가능해요"
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textColor = UIColor(hex: "9C9C9C")
        return label
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
        
        self.createPickerView()
        self.dismissPickerView()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubviews(mogakLabel, regionLabel, subLabel)
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            $0.leading.equalToSuperview().offset(20)
        })
        
        regionLabel.snp.makeConstraints({
            $0.top.equalTo(mogakLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(regionLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
        })
    }
    
    private func configureTextField() {
        self.view.addSubview(regionTextField)
        self.view.addSubview(regionSubLabel)
        
        regionTextField.snp.makeConstraints({
            $0.top.equalTo(subLabel.snp.bottom).offset(38)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(33)
            $0.width.equalTo(101)
        })
        
        regionSubLabel.snp.makeConstraints({
            $0.top.equalTo(regionTextField.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
        
    }
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(53)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-53)
        })
    }
    
    private func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        regionTextField.inputView = pickerView
    }
    
    private func dismissPickerView() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let button = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(self.action))
        toolbar.setItems([button], animated: true)
        toolbar.isUserInteractionEnabled = true
        regionTextField.inputAccessoryView = toolbar
    }
    
    @objc private func action() {
        regionTextField.resignFirstResponder()
    }
    
    @objc private func nextButtonIsClicked() {
        if regionTextField.text == "" {
            let alert = UIAlertController(title: "경고", message: "모두 동의하셔야 다음 단계로 넘어갈 수 있어요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "다시 돌아가기", style: .cancel))
            present(alert, animated: true)
        } else {
            let mainVC = TabBarViewController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
        }
        
    }
    
    
}

extension ChooseRegionViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return region.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return region[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        regionTextField.text = region[row]
    }
}
