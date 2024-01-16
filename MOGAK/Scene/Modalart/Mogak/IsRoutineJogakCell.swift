//
//  IsRoutineJogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/23.
//

import Foundation
import UIKit

class IsRoutineJogakCell: UICollectionViewCell {
    static let identifier: String = "IsRoutineJogakCell"

    var goalRepeatDayLabelText: String = ""
    var goalCategoryLabelTextColor: String = "475FFD"
    
    var goalContentLabelText: String = ""
    
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
    
    private lazy var goalContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = goalContentLabelText
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var routineIcon: UIImageView = {
        let image = UIImageView(image: UIImage(named: "routineIcon"))
        image.tintColor = UIColor(hex: goalCategoryLabelTextColor)
        return image
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
        
        self.goalRepeatDayLabel.text = goalRepeatDayLabelText
        self.goalRepeatDayLabel.backgroundColor = UIColor(hex: goalCategoryLabelTextColor).withAlphaComponent(0.1)
        self.goalRepeatDayLabel.textColor = UIColor(hex: goalCategoryLabelTextColor)
        self.goalContentLabel.text = goalContentLabelText

        self.configureLayoutDayLabel()
    }
    
}

extension IsRoutineJogakCell {
    private func configureLayout() {
        self.addSubviews(routineIcon, goalRepeatDayLabel, goalContentLabel)
        
        routineIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(40)
        }
        
        
        goalContentLabel.snp.makeConstraints {
            $0.top.equalTo(goalRepeatDayLabel.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
    }
    
    func configureLayoutDayLabel() {
        goalRepeatDayLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.equalToSuperview().offset(43)
        }
    }
}
