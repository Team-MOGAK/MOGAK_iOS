//
//  RegionCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/06.
//

import UIKit
import SnapKit

class RegionCell: UITableViewCell {
    
    let name = UILabel().then {
        $0.text = ""
        $0.textColor = .black
        $0.font = UIFont.pretendard(.medium, size: 16)
    }
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage(named: "checkOff"), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setName(item: String) {
        self.name.text = item
    }
    
    func setCheckOn() {
        self.checkButton.setImage(UIImage(named: "checkOn"), for: .normal)
    }
    
    func setCheckOff() {
        self.checkButton.setImage(UIImage(named: "checkOff"), for: .normal)
    }
    
    private func configure() {
        [name, checkButton].forEach({self.addSubview($0)})
        
        name.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        })
        
        checkButton.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(20)
        })
    }
    
}
