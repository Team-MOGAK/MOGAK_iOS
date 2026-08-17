//
//  IsRoutineJogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/23.
//

import UIKit

/// 루틴으로 설정된 조각의 경우
final class IsRoutineJogakCell: UICollectionViewCell {
    static let identifier: String = "IsRoutineJogakCell"
    
    private lazy var badgeLabel: CustomPaddingLabel = {
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
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 16)
        label.textAlignment = .center
        return label
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
    
    func configure(badgeText: String, title: String, color: String) {
        badgeLabel.text = badgeText
        badgeLabel.backgroundColor = UIColor(hex: color).withAlphaComponent(0.1)
        badgeLabel.textColor = UIColor(hex: color)
        goalContentLabel.text = title
    }
    
}

extension IsRoutineJogakCell {
    /// 레이아웃 잡기
    private func configureLayout() {
        self.addSubviews(badgeLabel, goalContentLabel)

        goalContentLabel.snp.makeConstraints {
            $0.top.equalTo(badgeLabel.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        badgeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(10)
        }
    }
}
