//
//  SetModalartTitleModalViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/19.
//

import Foundation
import UIKit
import SnapKit

#if false
// Legacy MOGAK1 feature implementation (inactive after 1:1 migration to MOGAK2 MG_Presentation).

class SetModalartTitleModal: UIViewController {
    //MARK: - properties
    //모다라트 타이틀
    var modalArtTitle: String = ""
    
    //모다라트 배경색
    var titleBgColor: String!

    //모다라트 배경색으로 선택 가능한 컬러차트
    let titleColorPalette: [String] = ["#475FFD", "#11D796", "#009967", "#FF2323", "#F98A08", "#FF6827", "#9C31FF", "#21CAFF"]
    
    //완료를 눌렀을때 모다라트 타이틀이랑 중앙 모각 설정
    var changeMainMogak: ((_ mogakBGColor: String, _ mogakTitle: String) -> ())? = nil

    //모각 색 설정되었는지
    var isColorSelected: Bool = false
    
    //모각 타이틀이 설정 되었는지
    var isTitleSetUp: Bool = false
    
    var titleLabel: UILabel = {
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
    
    //MARK: - 컬러 차트
    var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetting()
        configureLayout()
        collectionViewSetUp()
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        changeCompleteBtn()
    }
    
    //MARK: - 뷰컨 셋팅(textField에 텍스트 넣어주기, addTarget달아주기)
    func viewSetting() {
        self.view.backgroundColor = .white

        titleSetTextField.delegate = self
        titleSetTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.cancelBtn.addTarget(self, action: #selector(cancelBtnTapped(_:)), for: .touchUpInside)
        self.completeBtn.addTarget(self, action: #selector(completeBtnTapped(_:)), for: .touchUpInside)
    }

    //MARK: - 터치됐을 때 설정
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - 취소버튼 눌렀을 때
    @objc func cancelBtnTapped(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 취소버튼 클릭")
        self.dismiss(animated: true)
    }
    
    //MARK: - 완료버튼 눌렀을 때
    @objc func completeBtnTapped(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 완료버튼 클릭🔥")
        
        guard let indexPath = colorCollectionView.indexPathsForSelectedItems?[0][1],
              let modalartNewTitle = titleSetTextField.text else { return }
        let selectedColor = titleColorPalette[indexPath]

        changeMainMogak?(selectedColor, modalartNewTitle) //컴플레션 터트려주기
        self.dismiss(animated: true)
    }
    
    //MARK: - textField가 변경되고 난 후
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let modalartTitle = textField.text else { return }
        print(#fileID, #function, #line, "- 변경? : \(modalartTitle)")
        if modalartTitle == "" {
            isTitleSetUp = false
        } else {
            isTitleSetUp = true
        }
        changeCompleteBtn()
    }
    
    //MARK: - 컬러 차트 collectionView 셋팅
    func collectionViewSetUp() {
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }
    
    //MARK: - 완료 버튼 backgroundColor & isEnabled변경
    func changeCompleteBtn() {
        if isColorSelected && isTitleSetUp {
            completeBtn.isEnabled = true
            completeBtn.backgroundColor = DesignSystemColor.signature.value
        } else {
            completeBtn.isEnabled = false
            completeBtn.backgroundColor = DesignSystemColor.gray3.value
        }
    }
    
}


extension SetModalartTitleModal {
    //MARK: - 뷰들 레이아웃 잡기
    private func configureLayout() {
        self.view.addSubviews(titleLabel, titleSetTextField, colorCollectionView, btnStackView)
        self.btnStackView.addArrangedSubview(cancelBtn)
        self.btnStackView.addArrangedSubview(completeBtn)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        titleSetTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleSetTextField.snp.bottom).offset(26)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        btnStackView.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleSetTextField.snp.bottom).offset(99)
            make.leading.equalToSuperview().offset(20)
        }
    }
}


extension SetModalartTitleModal: UITextFieldDelegate {
    //MARK: - 텍스트필드 글자수 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        print(#fileID, #function, #line, "- currentText🥺: \(currentText)")

        guard let stringLength = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringLength, with: string)
        return updatedText.count <= 20
    }
    
    //MARK: - return키 눌렀을때 키보드 내려가도록 설정
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}


extension SetModalartTitleModal: UICollectionViewDataSource{
    //MARK: - 한 섹션안에 컬러 차트의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titleColorPalette.count
    }

    //MARK: - cell 셋팅
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
        cell.color = UIColor(hex: titleColorPalette[indexPath.row])
        
        if titleColorPalette[indexPath.row] == titleBgColor { //만약에 지금 보여줘야 하는 셀이 타이틀 백그라운드 색이랑 같다면 해당 컬러차트 표시
            isColorSelected = true
            cell.innerView.backgroundColor = .white
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            changeCompleteBtn()
        }
        
        cell.setUpColorView()
        cell.setUpInnerView()
        
        return cell
    }
    
}


extension SetModalartTitleModal: UICollectionViewDelegate {
    //MARK: - 컬러가 선택되었을 때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- selected🔥")
        if !isColorSelected {
            isColorSelected = true
            changeCompleteBtn()
        }
    }
}

#endif
