//
//  ScheduleTableViewCell.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/07/24.
//

import UIKit
import SnapKit

class ScheduleTableViewCell : UITableViewCell {
    
    private lazy var cellButton : UIButton = {
        let CellButton = UIButton()
        CellButton.setImage(UIImage(named: "ScheduleDefault"), for: .normal)
        CellButton.backgroundColor = .clear //백그라운드색
        CellButton.layer.cornerRadius = 5 //둥글기
        return CellButton
    }()
    
     lazy var cellLabel : UILabel = {
        let cellLabel = UILabel()
        cellLabel.text = "두줄까지쓸수있어요.\n두줄까지쓸수있어요."
        cellLabel.textAlignment = .left
        return cellLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        CellUI()
    }
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func CellUI(){
        contentView.addSubview(cellButton)
        contentView.addSubview(cellLabel)
        
        cellButton.snp.makeConstraints{
            $0.width.height.equalTo(20)
            $0.leading.equalTo(contentView).offset(10)
            $0.centerY.equalTo(contentView)
        }
        cellLabel.snp.makeConstraints{
            $0.centerY.equalTo(cellButton)
            $0.leading.equalTo(cellButton).offset(10)
        }
    }
}
