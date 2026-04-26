//
//  EllipsisAlertBottomSheetView.swift
//  MOGAK
//
//  Created by 이재혁 on 11/5/23.
//

import Foundation
import UIKit
import SnapKit

class MakeTitleAlertBottomSheetView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "작은 목표를 설정하기 전에\n큰 목표를 추가해주세요."
        label.textColor = DesignSystemColor.black.value
        label.numberOfLines = 2
        label.font = DesignSystemFont.semibold20L140.value
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 가장 원하는 목표를 적어주세요."
        label.textColor = DesignSystemColor.black.value.withAlphaComponent(0.6)
        label.numberOfLines = 1
        label.font = DesignSystemFont.regular14L150.value
        return label
    }()
    
    var noBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("아니요", for: .normal)
        btn.backgroundColor = DesignSystemColor.signatureBag.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()
    
    var okayBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("네", for: .normal)
        btn.backgroundColor = DesignSystemColor.signature.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()
    
    var stk: UIStackView = {
        let stk = UIStackView()
        stk.axis = .horizontal
        stk.alignment = .fill
        stk.spacing = 10
        stk.distribution = .fillEqually
        return stk
    }()
    
    @objc func noBtnTapped() {
        print(#fileID, #function, #line, "- 아니오 button clicked")
    }
    
    @objc func okayBtnTapped() {
        print(#fileID, #function, #line, "- yes button tapped")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewUISetting()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func viewUISetting() {
        self.backgroundColor = DesignSystemColor.white.value
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        stk.addArrangedSubview(noBtn)
        stk.addArrangedSubview(okayBtn)
    }
}

//MARK: - 오토레이아웃 설정
extension MakeTitleAlertBottomSheetView {
    private func configureLayout() {
        self.addSubviews(titleLabel, subTitleLabel, stk)
        
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
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(subTitleLabel.snp.top).offset(25)
        }
    }
}
