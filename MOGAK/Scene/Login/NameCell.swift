//
//  NameCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/12.
//

import UIKit
import SnapKit

class NameCell: UITableViewCell {
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .left
        return label
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
    
    private func configure() {
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints({
            $0.leading.equalTo(contentView).offset(0)
        })
        
    }
    
}
