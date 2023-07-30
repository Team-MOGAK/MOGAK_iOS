//
//  CategoryFilterCollectionViewCell.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/07/29.
//

import UIKit

class CategoryFilterCollectionViewCell: UICollectionViewCell {
    
    let categoryButton: UIButton = {
        let button = UIButton()
        // 버튼의 스타일과 다른 설정들을 지정합니다.
        // ...
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupButtonConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //setupButtonConstraints()
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
