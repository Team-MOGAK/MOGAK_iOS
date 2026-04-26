//
//  SegmentCollectionViewCell.swift
//  MOGAK
//
//  Created by 이재혁 on 11/8/23.
//

// Segment 기능을 대체하기 위한 collectionview의 cell입니다.

import UIKit
import SnapKit

class SegmentCollectionViewCell: UICollectionViewCell {
    
    let textLabel = UILabel().then {
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "BFC3D4")
        $0.text = ""
    }
    
    let underLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "475FFD")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
//    // 움직일 underLineView의 leadingAnchor 따로 작성
//    private lazy var leadingDistance: NSLayoutConstraint = {
//        return underLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
//    }()
    
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
        self.contentView.addSubviews(textLabel, underLineView)
        
        textLabel.snp.makeConstraints({
            $0.center.equalToSuperview()
        })
        
        underLineView.snp.makeConstraints({
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalTo(contentView.snp.width)
        })
    }
}
