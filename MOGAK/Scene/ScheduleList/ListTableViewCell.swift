//
//  ListTableViewCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/16.
//

import UIKit
import SnapKit

class ListTableViewCell: UITableViewCell {
    
    private let containerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor(red: 0.749, green: 0.765, blue: 0.831, alpha: 0.5).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()
    
    let statusView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(hex: "E8EBFE")
        return view
    }()
    
    let statusLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    private let categoryView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(hex: "F1F3FA")
        return view
    }()
    
    let categoryLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor(hex: "24252E")
        label.font = UIFont.pretendard(.medium, size: 16)
        return label
    }()
    
    private let ellipsisButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(hex: "6E707B")
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureContainerView()
        configureButton()
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(backColor: UIColor, titleText: String, statusText: String, categoryText: String, statusTextColor: UIColor) {
        statusView.backgroundColor = backColor
        titleLabel.text = titleText
        statusLabel.text = statusText
        categoryLabel.text = categoryText
        statusLabel.textColor = statusTextColor
    }
    
    private func configureLabel() {
        containerView.addSubview(titleLabel)
        containerView.addSubviews(statusLabel, categoryLabel)
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(46)
            $0.leading.equalTo(containerView.snp.leading).offset(16)
        })
        
        statusLabel.snp.makeConstraints({
            $0.centerX.equalTo(statusView)
            $0.centerY.equalTo(statusView)
        })
        
        categoryLabel.snp.makeConstraints({
            $0.centerX.equalTo(categoryView)
            $0.centerY.equalTo(categoryView)
        })
    }
    
    private func configureButton() {
        containerView.addSubviews(statusView, categoryView, ellipsisButton)
        
        statusView.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(16)
            $0.leading.equalTo(containerView.snp.leading).offset(16)
            $0.width.equalTo(57)
            $0.height.equalTo(22)
        })
        
        categoryView.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(16)
            $0.leading.equalTo(statusView.snp.trailing).offset(8)
            $0.width.equalTo(57)
            $0.height.equalTo(22)
        })
        
        ellipsisButton.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(24)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-16)
            $0.width.equalTo(15)
            $0.height.equalTo(3)
        })
    }
    
    private func configureContainerView() {
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints({
            $0.top.equalTo(contentView.snp.top).offset(24)
            $0.leading.trailing.equalTo(contentView).inset(20)
            $0.height.equalTo(108)
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
