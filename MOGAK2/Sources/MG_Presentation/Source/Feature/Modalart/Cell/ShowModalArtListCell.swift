//
//  ShowModalArtListCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

final class ShowModalArtListCell: UITableViewCell {
    static let identifier = String(describing: ShowModalArtListCell.self)
    
    private let modalartLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        contentView.addSubview(modalartLabel)
        
        modalartLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(16)
            make.height.equalTo(53)
        }
    }
    
    func configure(name: String) {
        modalartLabel.text = name
        if name.hasPrefix("내 모다라트") {
            modalartLabel.textColor = DesignSystemColor.gray3.value
        } else if name == "모다라트 추가" {
            modalartLabel.textColor = DesignSystemColor.signature.value
        } else {
            modalartLabel.textColor = DesignSystemColor.black.value
        }
        modalartLabel.textAlignment = .left
    }
}
