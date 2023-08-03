//
//  LocationFilterTableViewCell.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/07/28.
//

import UIKit

class LocationFilterTableViewCell: UITableViewCell {

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCellContainer()
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - CELL CONTAINER
    
    private let cellContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    // MARK: - LOCATION LABEL
    let locationLabel : UILabel = {
        let label = UILabel()
        label.text = "경기도"
        label.font = UIFont.pretendard(.semiBold, size: 16)
        label.textColor = UIColor(hex: "24252E")
        return label
    }()
    
    // MARK: - BUTTON
    private let selectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "MOGAK_button"), for: .normal)
        //button.tintColor = UIColor(hex: "FF4D77")
        
        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc func selectButtonTapped() {
            // 이미지 변경
            if selectButton.image(for: .normal) == UIImage(named: "MOGAK_button") {
                selectButton.setImage(UIImage(named: "MOGAK_button_filled"), for: .normal)
            } else {
                selectButton.setImage(UIImage(named: "MOGAK_button"), for: .normal)
            }
        }
    
    // MARK: - CONFIGURE
    private func configureCellContainer() {
        cellContainerView.addSubviews(locationLabel, selectButton)
        
        locationLabel.snp.makeConstraints({
            //$0.leading.top.bottom.equalTo(cellContainerView)
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(136)
            $0.height.equalTo(32)
        })
        
        selectButton.snp.makeConstraints({
            $0.width.height.equalTo(20)
            $0.trailing.equalTo(cellContainerView.snp.trailing)
            $0.centerY.equalToSuperview()
            
        })
    }
    
    private func configureCell() {
        contentView.addSubview(cellContainerView)
        
        cellContainerView.snp.makeConstraints({
            $0.leading.trailing.equalTo(contentView).inset(10)
            $0.bottom.equalTo(contentView).offset(9)
            $0.top.equalTo(contentView)
            $0.width.equalTo(330)
            $0.height.equalTo(32)
        })
    }
}
