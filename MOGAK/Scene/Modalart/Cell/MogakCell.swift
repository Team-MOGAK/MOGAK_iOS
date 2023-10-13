//
//  MogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/10.
//

import Foundation
import UIKit
import SnapKit

/// 사용자가 목표를 설정했을때 생성되는 모각
class MogakCell: UICollectionViewCell {
    static let identifier: String = "MogakCell"
    var goalCategoryLabelText: String = ""
    var goalCategoryLabelTextColor: String = "475FFD"
    var goalCategoryLabelBackgoundColor: String = "E8EBFE" //헥사코드로 진행할 예정
    
    var goalContentLabelText: String = ""
    
    private lazy var goalCategoryLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 6, bottom: 6, left: 12, right: 12)
        label.numberOfLines = 0
        label.text = self.goalCategoryLabelText
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textAlignment = .center
        label.backgroundColor = UIColor(hex: self.goalCategoryLabelBackgoundColor)
        label.textColor = UIColor(hex: self.goalCategoryLabelTextColor)
        return label
    }()
    
    private lazy var goalContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = goalContentLabelText
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var settingIcon: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "settingIcon"), for: .normal)
        button.addTarget(self, action: #selector(settingIconTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        print(#fileID, #function, #line, "- FullMogakCell")
        self.backgroundColor = DesignSystemColor.white.value
        self.layer.cornerRadius = 15
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellDataSetting() {
        print(#fileID, #function, #line, "- mogakCell⭐️ : \(goalContentLabelText)")
        self.goalCategoryLabel.text = goalCategoryLabelText
        self.goalCategoryLabel.backgroundColor = UIColor(hex: goalCategoryLabelBackgoundColor)
        self.goalCategoryLabel.textColor = UIColor(hex: goalCategoryLabelTextColor)
        self.goalContentLabel.text = goalContentLabelText
    }
    
    @objc func settingIconTapped() {
        print(#fileID, #function, #line, "- settingIconTapped⭐️")
    }
}

//MARK: - 오토레이아웃 잡기
extension MogakCell {
    private func configureLayout() {
        self.addSubviews(goalCategoryLabel, goalContentLabel, settingIcon)
        
        goalCategoryLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
        }
        
        goalContentLabel.snp.makeConstraints {
            $0.top.equalTo(goalCategoryLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        settingIcon.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
    }
}
