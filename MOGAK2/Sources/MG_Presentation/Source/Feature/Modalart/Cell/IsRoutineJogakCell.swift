//
//  IsRoutineJogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/23.
//

import Foundation
import UIKit

/// 루틴으로 설정된 조각의 경우
class IsRoutineJogakCell: UICollectionViewCell {
    static let identifier: String = "IsRoutineJogakCell"

    /// 반복 요일
    var goalRepeatDayLabelText: String = ""
    var goalCategoryLabelTextColor: String = "475FFD"
    
    /// 이행할 내용
    var goalContentLabelText: String = ""
    
    /// 반복 요일 label
    private lazy var goalRepeatDayLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 6, bottom: 6, left: 12, right: 12)
        label.sizeToFit()
        label.text = "0회"
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    /// 이행 내용 label
    private lazy var goalContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = goalContentLabelText
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 16)
        label.textAlignment = .center
        return label
    }()
    
    /// 루틴 모양 표시 -> 현재 사용 x
    private lazy var routineIcon: UIImageView = {
        let image = UIImageView(image: UIImage(named: "routineIcon"))
        image.tintColor = UIColor(hex: goalCategoryLabelTextColor)
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = DesignSystemColor.white.value
        self.layer.cornerRadius = 15
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 셀 세팅(ex. label 내용, 배경 색 등 설정)
    func cellDataSetting() {
        self.goalRepeatDayLabel.text = goalRepeatDayLabelText
        self.goalRepeatDayLabel.backgroundColor = UIColor(hex: goalCategoryLabelTextColor).withAlphaComponent(0.1)
        self.goalRepeatDayLabel.textColor = UIColor(hex: goalCategoryLabelTextColor)
        self.goalContentLabel.text = goalContentLabelText
    }
    
}

extension IsRoutineJogakCell {
    /// 레이아웃 잡기
    private func configureLayout() {
//        self.addSubviews(routineIcon, goalRepeatDayLabel, goalContentLabel)
        self.addSubviews(goalRepeatDayLabel, goalContentLabel)
        
//        routineIcon.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(15)
//            make.top.equalToSuperview().offset(40)
//        }
//        
        
        goalContentLabel.snp.makeConstraints {
            $0.top.equalTo(goalRepeatDayLabel.snp.bottom).offset(18)
//            $0.top.equalToSuperview().offset(18)
            $0.leading.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        goalRepeatDayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(10)
//            $0.leading.equalToSuperview().offset(43)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
    }
}
