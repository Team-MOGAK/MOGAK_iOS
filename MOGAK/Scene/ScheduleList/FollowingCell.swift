//
//  FollowingCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/08.
//

import UIKit
import SnapKit

class FollowingCell: UITableViewCell {
    
//    var followButtonClick: (() -> Void)?
    
    private let container = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let profileImage = UIImageView().then {
        $0.image = UIImage(named: "default")
        $0.clipsToBounds = true
    }
    
    private let userName = UILabel().then {
        $0.text = "김동동"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    
    private let job = UILabel().then {
        $0.text = "서비스기획자/PM"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.regular, size: 12)
    }
    
    private lazy var followButton = UIButton().then {
        $0.setTitle("팔로잉", for: .normal)
        $0.setTitleColor(UIColor(hex: "6E707B"), for: .normal)
        $0.backgroundColor = UIColor(hex: "EEF0F8")
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 14)
        $0.layer.cornerRadius = 8
        $0.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
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
        self.backgroundColor = .white
        self.contentView.isUserInteractionEnabled = false
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        self.addSubview(container)
        [profileImage, userName, job, followButton].forEach({container.addSubview($0)})
        profileImage.layer.cornerRadius = 18
        
        container.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        })
        
        profileImage.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(36)
        })
        
        userName.snp.makeConstraints({
            $0.top.equalTo(self.profileImage.snp.top).offset(2)
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(8)
        })
        
        job.snp.makeConstraints({
            $0.top.equalTo(self.userName.snp.bottom).offset(6)
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(8)
        })
        
        followButton.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(57)
            $0.height.equalTo(30)
        })
    }
    
    @objc private func followButtonTapped() {
        print("팔로우 버튼 클릭")
        if followButton.titleLabel?.text == "팔로잉" {
            self.followButton.setTitle("팔로우", for: .normal)
            self.followButton.backgroundColor = UIColor(hex: "E7F9F3")
            self.followButton.setTitleColor(UIColor(hex: "009967"), for: .normal)
            self.followButton.setImage(UIImage(systemName: "plus"), for: .normal)
            self.followButton.semanticContentAttribute = .forceRightToLeft
            self.followButton.tintColor = UIColor(hex: "009967")
            
            followButton.snp.updateConstraints({
                $0.width.equalTo(71)
            })
            
        } else if followButton.titleLabel?.text == "팔로우" {
            self.followButton.setTitle("팔로잉", for: .normal)
            self.followButton.backgroundColor = UIColor(hex: "EEF0F8")
            self.followButton.setTitleColor(UIColor(hex: "6E707B"), for: .normal)
            self.followButton.setImage(nil, for: .normal)
            
            followButton.snp.updateConstraints({
                $0.width.equalTo(57)
            })
            
        }
    }
    
}

