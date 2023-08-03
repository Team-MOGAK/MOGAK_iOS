//
//  CategoryCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/23.
//

import UIKit
import SnapKit

class CategoryCell: UICollectionViewCell {
    
    var isClicked = false
    
    let textLabel = UILabel().then {
        $0.font = UIFont.pretendard(.medium, size: 14)
        $0.textColor = UIColor(hex: "24252E")
        $0.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor(hex: "F1F3FA")
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 20
        
        
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.contentView.addSubview(textLabel)
        
        textLabel.snp.makeConstraints({
            $0.center.equalToSuperview()
        })
    }
}
