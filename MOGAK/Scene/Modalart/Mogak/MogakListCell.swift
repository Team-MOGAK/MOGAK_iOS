//
//  MogakListCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/07.
//

import Foundation
import UIKit
import SnapKit

class MogakListCell: UICollectionViewCell {
    static let identifier = "MogakListCell"
    var mogakTitle: String = ""
    
    var titleLabel: UILabel!
    var bottomBar: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLayout() {
        titleLabel = UILabel()
        bottomBar = UIView()
        
        self.addSubviews(titleLabel, bottomBar)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        bottomBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.width.equalToSuperview()
            make.height.equalTo(3)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                bottomBar.backgroundColor = DesignSystemColor.signature.value
            } else {
                bottomBar.backgroundColor = .clear
            }
        }
    }
}
