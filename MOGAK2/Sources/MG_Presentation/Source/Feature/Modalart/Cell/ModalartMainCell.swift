//
//  ModartMainCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/11.
//

import Foundation
import UIKit
import SnapKit

/// 모다라트 정중앙에 들어가는 Cell
final class ModalartMainCell: UICollectionViewCell {
    static let identifier = "ModalartMainCell"
    
    private lazy var goalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = DesignSystemColor.white.value
        label.font = UIFont.pretendard(.semiBold, size: 16)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layer.cornerRadius = 15
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, color: String) {
        goalLabel.text = title
        backgroundColor = UIColor(hex: color)
    }
    
}

//MARK: - 오토레이아웃 잡기
extension ModalartMainCell {
    private func configureLayout() {
        contentView.addSubview(goalLabel)
        
        goalLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
