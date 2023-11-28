//
//  AskDeleteModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/14.
//

import Foundation
import UIKit
import SnapKit

///진짜 삭제할건지 물어보는 모달
class AskDeleteModal: UIViewController {
    var startDelete: (() -> ())? = nil
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "정말 삭제하시겠어요?"
        label.textColor = DesignSystemColor.black.value
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold20L140.value
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "다시 복원할 수 없어요 :(\n신중하게 선택해주세요"
        label.textColor = DesignSystemColor.black.value.withAlphaComponent(0.6)
        label.numberOfLines = 2
        label.font = DesignSystemFont.regular14L150.value
        return label
    }()
    
    lazy var noBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("아니요", for: .normal)
        btn.backgroundColor = DesignSystemColor.signatureBag.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        btn.titleLabel?.font = DesignSystemFont.medium16L100.value
        btn.addTarget(self, action: #selector(noBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var yesBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("네", for: .normal)
        btn.backgroundColor = DesignSystemColor.signature.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = DesignSystemFont.medium16L100.value
        btn.addTarget(self, action: #selector(yesBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var stk: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 10
        stk.distribution = .fillEqually
        stk.addArrangedSubview(noBtn)
        stk.addArrangedSubview(yesBtn)
        return stk
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        self.view.backgroundColor = .white
    }
    
    @objc func noBtnTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func yesBtnTapped() {
        print(#fileID, #function, #line, "- 네 버튼 클릭")
        guard let startDelete = startDelete else { return }
        startDelete()
        self.dismiss(animated: true)
    }
}

//MARK: - 오토레이아웃 설정
extension AskDeleteModal {
    private func configureLayout() {
        self.view.addSubviews(titleLabel, subTitleLabel, stk)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(49)
            make.centerX.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        stk.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(subTitleLabel.snp.bottom)
                .offset(32)
            make.centerX.equalToSuperview()
        }
    }
}
