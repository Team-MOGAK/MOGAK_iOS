//
//  SetModalartTitleModalViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/19.
//

import UIKit
import SnapKit

final class SetModalartTitleModal: UIViewController {
    private let viewModel: MG2ModalartTitleEditorViewModel
    var onCancel: (() -> Void)?
    var onSubmit: ((String, String) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 가장 큰 목표는?"
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        return label
    }()
    
    private let titleSetTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "이루고픈 목표를 입력해 주세요."
        textField.setPlaceholderColor(DesignSystemColor.gray3.value)
        textField.textColor = .black
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("취소", for: .normal)
        btn.backgroundColor = DesignSystemColor.gray2.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.black.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()

    private let completeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("완료", for: .normal)
        btn.backgroundColor = DesignSystemColor.gray3.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()
    
    private let btnStackView: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 10
        stk.distribution = .fillEqually
        return stk
    }()
    
    //MARK: - 컬러 차트
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    init(viewModel: MG2ModalartTitleEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetting()
        configureLayout()
        collectionViewSetUp()
        titleSetTextField.text = viewModel.state.title
        if let selectedColorIndex = viewModel.selectedColorIndex {
            colorCollectionView.selectItem(
                at: IndexPath(item: selectedColorIndex, section: 0),
                animated: false,
                scrollPosition: []
            )
        }
        renderSubmitState()
    }
    
    //MARK: - 뷰컨 셋팅(textField에 텍스트 넣어주기, addTarget달아주기)
    private func viewSetting() {
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
    @objc private func cancelBtnTapped(_ sender: UIButton) {
        onCancel?()
    }
    
    //MARK: - 완료버튼 눌렀을 때
    @objc private func completeBtnTapped(_ sender: UIButton) {
        guard let submission = viewModel.submission() else { return }
        onSubmit?(submission.title, submission.color)
    }
    
    //MARK: - textField가 변경되고 난 후
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.updateTitle(textField.text ?? "")
        renderSubmitState()
    }
    
    //MARK: - 컬러 차트 collectionView 셋팅
    private func collectionViewSetUp() {
        colorCollectionView.register(MG2ColorSelectionCell.self, forCellWithReuseIdentifier: MG2ColorSelectionCell.identifier)
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }
    
    //MARK: - 완료 버튼 backgroundColor & isEnabled변경
    private func renderSubmitState() {
        completeBtn.isEnabled = viewModel.state.canSubmit
        completeBtn.backgroundColor = viewModel.state.canSubmit
            ? DesignSystemColor.signature.value
            : DesignSystemColor.gray3.value
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

        guard let stringLength = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringLength, with: string)
        return viewModel.canUpdateTitle(updatedText)
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
        viewModel.colors.count
    }

    //MARK: - cell 셋팅
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = colorCollectionView.dequeueReusableCell(
            withReuseIdentifier: MG2ColorSelectionCell.identifier,
            for: indexPath
        ) as? MG2ColorSelectionCell else { return UICollectionViewCell() }
        cell.configure(color: UIColor(hex: viewModel.colors[indexPath.row]))
        return cell
    }
    
}


extension SetModalartTitleModal: UICollectionViewDelegate {
    //MARK: - 컬러가 선택되었을 때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectColor(at: indexPath.row)
        renderSubmitState()
    }
}
