//
//  JogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/22.
//

import UIKit
import SnapKit

/// 루틴으로 설정되지 않는 조각
final class JogakCell: UICollectionViewCell {
    static let identifier: String = "JogakCell"
    
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
    
    func configure(title: String) {
        goalContentLabel.text = title
    }
    
}

extension JogakCell {
    /// 레이아웃 잡기
    private func configureLayout() {
        self.addSubviews(goalContentLabel)

        goalContentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

}
