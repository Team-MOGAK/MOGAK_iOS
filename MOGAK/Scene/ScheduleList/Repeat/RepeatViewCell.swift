//
//  RepeatViewCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/23.
//

import UIKit
import SnapKit

#if false
// Legacy MOGAK1 feature implementation (inactive after 1:1 migration to MOGAK2 MG_Presentation).

class RepeatCell: UICollectionViewCell {
    
    
    let textLabel = UILabel().then {
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
        $0.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor(hex: "EEF0F8")
        self.contentView.layer.masksToBounds = true
//        self.contentView.layer.cornerRadius = contentView.frame.width / 2
        self.contentView.layer.cornerRadius = 24
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

#endif
