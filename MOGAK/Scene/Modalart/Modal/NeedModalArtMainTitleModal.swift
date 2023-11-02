//
//  TitleModalartAlertBottomModalSheetView.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/20.
//
import Foundation
import UIKit
import SnapKit

///큰 목표가 없이 작은 목표 추가버튼을 눌렀을 때의 모달
class NeedModalArtMainTitleModal: UIView {
    var vc: UIViewController!
    
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

    var okayBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("확인", for: .normal)
        btn.backgroundColor = DesignSystemColor.signature.value
        btn.layer.cornerRadius = 10
        btn.setTitleColor(DesignSystemColor.white.value, for: .normal)
        btn.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return btn
    }()

    @objc func okayBtnTapped() {
        print(#fileID, #function, #line, "- yes button tapped")
        vc.dismiss(animated: true)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        viewUISetting()
        configureLayout()
        
        self.okayBtn.addTarget(vc, action: #selector(okayBtnTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func viewUISetting() {
        self.backgroundColor = DesignSystemColor.white.value
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
    }
}

//MARK: - 오토레이아웃 설정
extension NeedModalArtMainTitleModal {
    private func configureLayout() {
        self.addSubviews(titleLabel, subTitleLabel, okayBtn)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(49)
            make.centerX.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        okayBtn.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(25)
        }
    }
}
