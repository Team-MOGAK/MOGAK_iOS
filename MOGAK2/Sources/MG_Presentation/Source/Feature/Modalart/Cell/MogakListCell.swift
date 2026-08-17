//
//  MogakListCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/07.
//

import UIKit
import SnapKit

/// 모각 리스트(세부목표 화면에서 상단에 있는 모각 리스트)
final class MogakListCell: UICollectionViewCell {
    static let identifier = "MogakListCell"
    private let titleLabel = UILabel()
    private let bottomBar = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }

    private func configureLayout() {
        contentView.addSubviews(titleLabel, bottomBar)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-2)
        }
        
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(3)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            bottomBar.backgroundColor = isSelected
                ? DesignSystemColor.signature.value
                : .clear
        }
    }
}
