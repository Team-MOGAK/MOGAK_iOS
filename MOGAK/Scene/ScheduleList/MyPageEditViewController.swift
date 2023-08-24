//
//  MyPageEditViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/09.
//

import UIKit
import SnapKit

class MyPageEditViewController: UIViewController {
    
    private let profileImage = UIImageView().then {
        $0.image = UIImage(named: "default")
        $0.clipsToBounds = true
    }
    
    private let userName = UILabel().then {
        $0.text = "김동동"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.bold, size: 22)
    }
    
    private let job = UILabel().then {
        $0.text = "서비스기획자/PM"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.medium, size: 12)
    }
    
    private let changeProfileLabel = UILabel().then {
        $0.text = "프로필 사진 변경"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let changeProfileButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let changeNicknameLabel = UILabel().then {
        $0.text = "닉네임 변경"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let changeNicknameButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let changeJobLabel = UILabel().then {
        $0.text = "직무 변경"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let changeJobButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let logoutLabel = UILabel().then {
        $0.text = "로그아웃"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let logoutButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureProfile()
        self.configureSetting()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
        self.title = "프로필 수정"
    }
    
    private func configureProfile() {
        [profileImage, userName, job].forEach({view.addSubview($0)})
        
        profileImage.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        })
        
        userName.snp.makeConstraints({
            $0.top.equalTo(self.profileImage.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        })
        
        job.snp.makeConstraints({
            $0.top.equalTo(self.userName.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        })
    }
    
    private func configureSetting() {
        [changeProfileLabel, changeProfileButton, changeNicknameLabel, changeNicknameButton, changeJobLabel, changeJobButton, logoutLabel, logoutButton].forEach({view.addSubview($0)})
        
        changeProfileLabel.snp.makeConstraints({
            $0.top.equalTo(job.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        changeProfileButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.changeProfileLabel.snp.centerY)
            $0.width.height.equalTo(16)
        })
        
        changeNicknameLabel.snp.makeConstraints({
            $0.top.equalTo(changeProfileLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        changeNicknameButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.changeNicknameLabel.snp.centerY)
            $0.width.height.equalTo(16)
        })
        
        changeJobLabel.snp.makeConstraints({
            $0.top.equalTo(changeNicknameLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        changeJobButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.changeJobLabel.snp.centerY)
            $0.width.height.equalTo(16)
        })
        
        logoutLabel.snp.makeConstraints({
            $0.top.equalTo(changeJobLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        logoutButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.logoutLabel.snp.centerY)
            $0.width.height.equalTo(16)
        })
    }
    
}
