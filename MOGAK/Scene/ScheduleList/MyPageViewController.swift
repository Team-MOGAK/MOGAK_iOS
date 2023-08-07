//
//  MyPageViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/07.
//

import UIKit
import SnapKit
import Then

class MyPageViewController: UIViewController {
    
    private let profileImage = UIImageView().then {
        $0.image = UIImage(named: "default")
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
        $0.layer.borderColor = UIColor.clear.cgColor
        $0.contentMode = .scaleAspectFill
    }
    
    private let name = UILabel().then {
        $0.text = "김동동"
        $0.font = UIFont.pretendard(.bold, size: 22)
        $0.textColor = UIColor(hex: "000000")
    }
    
    private let job = UILabel().then {
        $0.text = "서비스기획자/PM"
        $0.font = UIFont.pretendard(.medium, size: 12)
        $0.textColor = UIColor(hex: "000000")
    }
    
    private let editButton = UIButton().then {
        $0.setTitle("프로필 수정", for: .normal)
        $0.setTitleColor(UIColor(hex: "475FFD"), for: .normal)
        $0.backgroundColor = UIColor(hex: "E8EBFE")
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 16)
        $0.titleLabel?.textAlignment = .center
        $0.layer.cornerRadius = 10
    }
    
    private let shareButton = UIButton().then {
        $0.setTitle("프로필 공유", for: .normal)
        $0.setTitleColor(UIColor(hex: "6E707B"), for: .normal)
        $0.backgroundColor = UIColor(hex: "F1F3FA")
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 16)
        $0.titleLabel?.textAlignment = .center
        $0.layer.cornerRadius = 10
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    private let pushLabel = UILabel().then {
        $0.text = "푸시 알림 설정"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let pushButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let notiLabel = UILabel().then {
        $0.text = "공지사항"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let notiButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let askLabel = UILabel().then {
        $0.text = "문의하기"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let askButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let permLabel = UILabel().then {
        $0.text = "이용약관"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let permButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let privacyLabel = UILabel().then {
        $0.text = "개인정보 처리방침"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let privacyButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let gpsLabel = UILabel().then {
        $0.text = "위치 서비스 이용동의"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let gpsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    private let versionLabel = UILabel().then {
        $0.text = "버전 정보"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let versionNumberLabel = UILabel().then {
        $0.text = "v1.1.1"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "BFC3D4")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureProfile()
        self.configureSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
    }
    
    private func configureNavBar() {
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
        self.title = "내 설정"
    }
    
    private func configureProfile() {
        [profileImage, name, job, buttonStackView].forEach({view.addSubview($0)})
        [editButton, shareButton].forEach({buttonStackView.addArrangedSubview($0)})
        
        profileImage.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(44)
        })
        
        name.snp.makeConstraints({
            $0.top.equalTo(self.profileImage.snp.top)
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(11)
        })
        
        job.snp.makeConstraints({
            $0.top.equalTo(self.name.snp.bottom).offset(8)
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(11)
        })
        
        buttonStackView.snp.makeConstraints({
            $0.top.equalTo(self.job.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.05)
        })
        
    }
    
    private func configureSetting() {
        [pushLabel, pushButton, notiLabel, notiButton, askLabel, askButton, permLabel, permButton, privacyLabel, privacyButton, gpsLabel, gpsButton, versionLabel, versionNumberLabel].forEach({view.addSubview($0)})
        
        pushLabel.snp.makeConstraints({
            $0.top.equalTo(self.buttonStackView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        pushButton.snp.makeConstraints({
            $0.centerY.equalTo(self.pushLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(16)
        })
        
        notiLabel.snp.makeConstraints({
            $0.top.equalTo(self.pushLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        notiButton.snp.makeConstraints({
            $0.centerY.equalTo(self.notiLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(16)
        })
        
        askLabel.snp.makeConstraints({
            $0.top.equalTo(self.notiLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        askButton.snp.makeConstraints({
            $0.centerY.equalTo(self.askLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(16)
        })
        
        permLabel.snp.makeConstraints({
            $0.top.equalTo(self.askLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        permButton.snp.makeConstraints({
            $0.centerY.equalTo(self.permLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(16)
        })
        
        privacyLabel.snp.makeConstraints({
            $0.top.equalTo(self.permLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        privacyButton.snp.makeConstraints({
            $0.centerY.equalTo(self.privacyLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(16)
        })
        
        gpsLabel.snp.makeConstraints({
            $0.top.equalTo(self.privacyLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        gpsButton.snp.makeConstraints({
            $0.centerY.equalTo(self.gpsLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(16)
        })
        
        versionLabel.snp.makeConstraints({
            $0.top.equalTo(self.gpsLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        versionNumberLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.versionLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
        })
    }
    
}
