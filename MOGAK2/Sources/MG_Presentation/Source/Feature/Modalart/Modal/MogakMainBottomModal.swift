//
//  MogakMainBottomModal.swift
//  MOGAK
//
//  Created by 김라영 on 2024/02/19.
//

import Foundation
import UIKit
import SnapKit

/// 조각 페이지에서 중앙 모각 탭시 올라오는 모각 뷰
class MogakMainBottomModalViewController: UIViewController {
    weak var delegate: MogakSettingButtonTappedDelegate?
    var selectedMogak: DetailMogakData = DetailMogakData(mogakId: 0, title: "", bigCategory: MainCategory(id: 0, name: ""), smallCategory: "", color: "")
  
    var startDeleteJogak: (() -> ())? = nil
    
    private lazy var categoryLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 4, bottom: 4, left: 10, right: 10)
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var mogakTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = DesignSystemFont.medium18140.value
        return label
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("삭제", for: .normal)
        btn.backgroundColor = DesignSystemColor.signatureBag.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        btn.titleLabel?.font = DesignSystemFont.medium16L100.value
        btn.addTarget(self, action: #selector(deleteBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("수정", for: .normal)
        btn.backgroundColor = DesignSystemColor.signature.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = DesignSystemFont.medium16L100.value
        btn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnstk: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 10
        stk.distribution = .fillEqually
        stk.addArrangedSubview(deleteBtn)
        stk.addArrangedSubview(editBtn)
        return stk
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelSetting()
        configureLayout()
        self.view.backgroundColor = .white
    }
    
    func labelSetting() {
        categoryLabel.text = selectedMogak.bigCategory.name
        categoryLabel.textColor = UIColor(hex: selectedMogak.color ?? "#475FFD")
        categoryLabel.backgroundColor = UIColor(hex: selectedMogak.color ?? "#475FFD").withAlphaComponent(0.1)
        
        mogakTitleLabel.text = selectedMogak.title
    }
    
    //MARK: - 모각 delete버튼 클릭시
    @objc func deleteBtnTapped() {
        self.dismiss(animated: true)
        guard let startDeleteJogak = self.startDeleteJogak else { return }
        //이걸 modal을 부르는 곳에서 데이터를 startDeleteJogak을 부른다
        startDeleteJogak()
    }
    
    //MARK: - 모각 수정
    @objc func editBtnTapped() {
        print(#fileID, #function, #line, "- 네 버튼 클릭")
        self.dismiss(animated: true)
        print(#fileID, #function, #line, "- delegate:\(delegate)")
        delegate?.cellButtonTapped(mogakData: self.selectedMogak)
        
    }
    
}

extension MogakMainBottomModalViewController {
    func configureLayout() {
        self.view.addSubviews(categoryLabel, mogakTitleLabel, btnstk)
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.leading.equalToSuperview().offset(20)
        }
        
        mogakTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }

        btnstk.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.top.equalTo(mogakTitleLabel.snp.bottom).offset(13)
            make.leading.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
    }
}
