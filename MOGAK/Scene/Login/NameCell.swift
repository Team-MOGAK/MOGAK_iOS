//
//  NameCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/12.
//

import UIKit
import SnapKit

class NameCell: UITableViewCell {
    
    var checkCount = 0
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    
    let checkButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .orange
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 이전 셀의 상태를 초기화합니다.
        checkButton.isHidden = true
    }
    
    private func configure() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(checkButton)
        checkButton.isHidden = true
        self.selectionStyle = .none
        
        nameLabel.snp.makeConstraints({
            $0.leading.equalTo(contentView).offset(0)
        })
        
        checkButton.snp.makeConstraints({
            $0.trailing.equalTo(contentView)
            $0.centerY.equalTo(contentView)
        })
        
    }
    
}
