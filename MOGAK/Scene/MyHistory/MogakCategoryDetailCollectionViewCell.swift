//
//  MogakCategoryDetailCollectionViewCell.swift
//  MOGAK
//
//  Created by 이재혁 on 12/20/23.
//

import UIKit
import SnapKit

class MogakCategoryDetailCollectionViewCell: UICollectionViewCell {
    func configureMogakCategory(MogakCategoryText: String) {
        mogakNameLabel.text = MogakCategoryText
    }
    
    let mogakNameView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor(hex: "FFFFFF")
        return view
    }()
    
    let mogakNameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.pretendard(.medium, size: 14)
        label.textColor = UIColor(hex: "BFC3D4")
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.contentView.layer.masksToBounds = true
        
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.contentView.addSubviews(mogakNameView, mogakNameLabel)
        
        mogakNameView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(5)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(34)
            $0.width.equalTo(mogakNameLabel.snp.width)
        })
        
        mogakNameLabel.snp.makeConstraints({
            $0.centerY.centerX.equalTo(mogakNameView)
        })
        
    }
}
