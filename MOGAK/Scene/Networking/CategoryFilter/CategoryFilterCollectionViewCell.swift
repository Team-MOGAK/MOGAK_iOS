//
//  CategoryFilterCollectionViewCell.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/07/29.
//

import UIKit
import SnapKit

class CategoryFilterCollectionViewCell: UICollectionViewCell {
    
    var isClicked = false
    
    let textLabel = UILabel().then {
        $0.font = UIFont.pretendard(.medium, size: 14)
        $0.textColor = UIColor(hex: "24252E")
        $0.text = ""
    }
    
    let categoryButton: UIButton = {
        let button = UIButton()
        // 버튼의 스타일과 다른 설정들을 지정합니다.
        // ...
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor(hex: "F1F3FA")
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 20
        
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //setupButtonConstraints()
    }
    
    private func configureUI() {
        self.contentView.addSubview(textLabel)
        
        textLabel.snp.makeConstraints({
            $0.center.equalToSuperview()
        })
    }
    
    private lazy var locationFilterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.pretendard(.semiBold, size: 14)
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor(hex: "24252E"), for: .normal)
        //button.tintColor = UIColor(hex: "F1F3FA")
        button.backgroundColor = UIColor(hex: "F1F3FA")
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        
        //button.addTarget(self, action: #selector(showLocationFilterSheetView(_:)), for: .touchUpInside)
        
        return button
    }()
    
}
