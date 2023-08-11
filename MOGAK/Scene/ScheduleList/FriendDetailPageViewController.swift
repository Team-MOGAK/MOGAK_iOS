//
//  FriendDetailPageViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/11.
//

import UIKit
import SnapKit

class FriendDetailPageViewController: UIViewController {
    
    private lazy var profileImage : UIImageView = {
        let view = UIImageView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.image = UIImage(named: "default")
        return view
    }()
    
    private let profileName : UILabel = {
        let label = UILabel()
        label.text = "김동동"
        label.font = UIFont.pretendard(.bold, size: 22)
        label.textColor = UIColor(hex: "FFFFFF")
        return label
    }()
    
    private let profileJob : UILabel = {
        let label = UILabel()
        label.text = "서비스기획자/PM"
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textColor = UIColor(hex: "FFFFFF")
        return label
    }()
    
    private lazy var mogakerLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAKER 2"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = UIColor(hex: "FFFFFF")
        let gesture = UITapGestureRecognizer(target: self, action: #selector(goToFriendPage))
        label.addGestureRecognizer(gesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let mogakeeLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAKEE 5"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = UIColor(hex: "FFFFFF")
        return label
    }()
    
    private let followLineView : UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "FFFFFF").cgColor
        return view
    }()
    
    private lazy var followButton = UIButton().then {
        $0.setTitle("팔로잉", for: .normal)
        $0.setTitleColor(UIColor(hex: "475FFD"), for: .normal)
        $0.backgroundColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.6)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 14)
        $0.layer.cornerRadius = 10
        $0.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "475FFD")
        self.configureNavBar()
        self.configureTop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
    }
    
    
    private func configureNavBar() {
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: "ffffff"), .font: UIFont.pretendard(.semiBold, size: 18)
            ]
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "verticalEllipsis"), style: .plain, target: self, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "ffffff")
        self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        self.title = "친구 프로필"
    }
    
    private func configureTop() {
        [profileImage, profileName, profileJob, mogakerLabel, mogakeeLabel, followLineView, followButton].forEach({view.addSubview($0)})
        
        profileImage.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(21)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(44)
        })
        
        profileName.snp.makeConstraints({
            $0.top.equalTo(profileImage.snp.top)
            $0.leading.equalTo(profileImage.snp.trailing).offset(11)
        })
        
        profileJob.snp.makeConstraints({
            $0.top.equalTo(profileName.snp.bottom).offset(8)
            $0.leading.equalTo(profileImage.snp.trailing).offset(11)
        })
        
        mogakerLabel.snp.makeConstraints({
            $0.top.equalTo(profileJob.snp.bottom).offset(12)
            $0.leading.equalTo(self.profileJob.snp.leading)
        })
        
        followLineView.snp.makeConstraints({
            $0.centerY.equalTo(mogakerLabel.snp.centerY)
            $0.leading.equalTo(mogakerLabel.snp.trailing).offset(16)
            $0.height.equalTo(12)
            $0.width.equalTo(1)
        })
        
        mogakeeLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.mogakerLabel.snp.centerY)
            $0.leading.equalTo(followLineView.snp.trailing).offset(16)
        })
        
        followButton.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(57)
            $0.height.equalTo(30)
        })

        
    }

    
    @objc private func goToFriendPage() {
        
    }
    
    @objc private func followButtonTapped() {
        if followButton.titleLabel?.text == "팔로잉" {
            self.followButton.setTitle("팔로우", for: .normal)
            self.followButton.backgroundColor = UIColor(hex: "ffffff")
            self.followButton.setImage(UIImage(systemName: "plus"), for: .normal)
            self.followButton.semanticContentAttribute = .forceRightToLeft
            self.followButton.tintColor = UIColor(hex: "475FFD")
            
            followButton.snp.updateConstraints({
                $0.width.equalTo(71)
            })
            
        } else if followButton.titleLabel?.text == "팔로우" {
            self.followButton.setTitle("팔로잉", for: .normal)
            self.followButton.backgroundColor = UIColor(hex: "ffffff").withAlphaComponent(0.6)
            self.followButton.setImage(nil, for: .normal)
            
            followButton.snp.updateConstraints({
                $0.width.equalTo(57)
            })
        }
    }
    
}
