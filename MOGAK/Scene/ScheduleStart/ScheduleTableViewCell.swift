//
//  ScheduleTableViewCell.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/07/24.
//

import UIKit
import SnapKit

class ScheduleTableViewCell : UITableViewCell {

     let cellImage : UIImageView = {
        let cellImage = UIImageView()
        cellImage.clipsToBounds = true
        cellImage.backgroundColor = .clear //백그라운드색
        cellImage.layer.cornerRadius = 5 //둥글기
        return cellImage
    }()
    
    let cellLabel : UILabel = {
        let cellLabel = UILabel()
        cellLabel.numberOfLines = 2
        cellLabel.textAlignment = .left
        return cellLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        CellUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func CellUI(){
        contentView.addSubview(cellImage)
        contentView.addSubview(cellLabel)
        
        cellImage.snp.makeConstraints{
            $0.width.height.equalTo(20)
           $0.leading.equalTo(contentView).offset(10)
            $0.centerY.equalTo(contentView)
        }
        cellLabel.snp.makeConstraints{
            $0.centerY.equalTo(cellImage)
            $0.leading.equalTo(cellImage.snp.trailing).offset(10)
        }
        

        
        layer.shadowColor = UIColor.darkGray.cgColor         //그림자 효과 추후 적용 예정
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.06
        contentView.layer.shadowRadius = 10
        
    }
    
 
}
