//
//  EmptyJogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/08.
//

import Foundation
import UIKit
import SnapKit

/// 설정이 안된 조각
class EmptyJogakCell: UICollectionViewCell {
    static let identifier = "EmptyJogakCell"
    
    private lazy var goalLabel : CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 6, bottom: 6, left: 12, right: 12)
        label.text = "행동"
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = DesignSystemColor.gray5.value
        label.backgroundColor = DesignSystemColor.gray2.value
        label.font = UIFont.pretendard(.medium, size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.text = "목표를 위한 \n행동을 \n생성해주세요."
        label.textColor = DesignSystemColor.gray3.value
        label.numberOfLines = 3
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
}

extension EmptyJogakCell {
    private func configureLayout() {
        self.addSubviews(goalLabel, commentLabel)
        
        goalLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
            $0.height.equalTo(25)
        }
        
        commentLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(goalLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(13)
        }
    }
}
