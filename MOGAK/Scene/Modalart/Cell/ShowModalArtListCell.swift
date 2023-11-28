//
//  ShowModalArtListCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

class ShowModalArtListCell: UITableViewCell {
    static let identifier: String = "ShowModalArtListCell"
    var modalartName: String = ""
    
    private var modalartLabel: UILabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
        setUpLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureLayout() {
        modalartLabel = UILabel()
        contentView.addSubview(modalartLabel)
        
        modalartLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(16)
            make.height.equalTo(53)
        }
    }
    
    func setUpLabel() {
        modalartLabel.text = modalartName
        if modalartName.prefix(6) == "내 모다라트" {
            modalartLabel.textColor = DesignSystemColor.gray3.value
        } else if modalartName.prefix(7) == "모다라트 추가" {
            modalartLabel.textColor = DesignSystemColor.signature.value
        } else {
            modalartLabel.textColor = DesignSystemColor.black.value
        }
        modalartLabel.textAlignment = .left
//        modalartLabel.backgroundColor = .red
    }
}

