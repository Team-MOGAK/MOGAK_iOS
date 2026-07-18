//
//  NameCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/12.
//

import UIKit
import SnapKit

final class MG2NameCell: UITableViewCell {
    private let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkOff"), for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, isChecked: Bool) {
        textLabel?.text = name
        checkButton.setImage(UIImage(named: isChecked ? "checkOn" : "checkOff"), for: .normal)
    }

    private func configure() {
        contentView.addSubview(checkButton)
        
        checkButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(25)
        })
    }
}
