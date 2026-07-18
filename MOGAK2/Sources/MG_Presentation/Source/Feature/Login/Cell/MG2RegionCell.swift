//
//  RegionCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/06.
//

import UIKit
import SnapKit
import Then

final class MG2RegionCell: UITableViewCell {
    
    let name = UILabel().then {
        $0.text = ""
        $0.textColor = .black
        $0.font = UIFont.pretendard(.medium, size: 16)
    }
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage(named: "checkOff"), for: .normal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, isChecked: Bool) {
        self.name.text = name
        checkButton.setImage(UIImage(named: isChecked ? "checkOn" : "checkOff"), for: .normal)
    }
    
    private func configure() {
        [name, checkButton].forEach(contentView.addSubview)
        
        name.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        })
        
        checkButton.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(25)
        })
    }
    
}
