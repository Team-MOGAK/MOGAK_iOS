//
//  MyPageEditViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/09.
//

import UIKit
import SnapKit
import Combine
import Alamofire

class MyPageEditViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    private let profileImage = UIImageView().then {
        $0.image = UIImage(named: "default")
//        $0.layer.cornerRadius = 50
//        $0.clipsToBounds = true
    }
    
    private let userName = UILabel().then {
        $0.text = RegisterUserInfo.shared.nickName
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.bold, size: 22)
    }
    
    private let job = UILabel().then {
        $0.text = RegisterUserInfo.shared.userJob
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.medium, size: 12)
    }
    
    private let changeProfileAndNicknameLabel = UILabel().then {
        $0.text = "프로필 사진/닉네임 변경"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let changeProfileAndNicknameButton = UIButton().then {
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
    
    private let userDeleteLabel = UILabel().then {
        $0.text = "회원탈퇴"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let userDeleteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.configureNavBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.configureProfile()
        self.configureSetting()
        
        changeProfileAndNicknameButton.addTarget(self, action: #selector(userNicknameProfileChangeTapped), for: .touchUpInside)
        changeJobButton.addTarget(self, action: #selector(userJobChangeTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        userDeleteButton.addTarget(self, action: #selector(userDelete), for: .touchUpInside)
        
        userProfileSetting()
    }
    
    func userProfileSetting() {
        //닉네임 변경 반영
        RegisterUserInfo.shared.$nickName.sink { nickname in
            self.userName.text = nickname
        }
        .store(in: &cancellables)
        
        //직무 변경 반영
        RegisterUserInfo.shared.$userJob.sink(receiveValue: { job in
            self.job.text = job
        })
        .store(in: &cancellables)
        
        //프로필 사진 변경 반영
        RegisterUserInfo.shared.$profileImage.sink { image in
            print(#fileID, #function, #line, "- image: \(image)")
            if image == nil {
                self.profileImage.image = UIImage(named: "setProfile")
            } else {
                self.profileImage.image = image
            }
            
        }
        .store(in: &cancellables)
    }
    
    override func viewDidLayoutSubviews() {
        print(#fileID, #function, #line, "- self.profileImage.frame.height: \(self.profileImage.frame.height)")
        profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.clipsToBounds = true
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
        self.title = "프로필 수정"
    }

    //MARK: - 유저 닉네임 & 이미지 변경 텝 선택
    @objc func userNicknameProfileChangeTapped() {
        print(#fileID, #function, #line, "- 닉네임 변경")
        let nicknameVC = NicknameViewController()
        nicknameVC.nicknameAndImageChange = true
        self.navigationController?.pushViewController(nicknameVC, animated: true)
    }
    
    //MARK: - 직업 변경 탭 선택
    @objc func userJobChangeTapped() {
        let jobVC = ChooseJobViewController()
        jobVC.changeJob = true
        self.navigationController?.pushViewController(jobVC, animated: true)
    }
    
    //MARK: - 로그아웃 요청
    @objc func logout() {
        print(#fileID, #function, #line, "- 로그아웃")
        UserNetwork.shared.userLogout { result in
            switch result {
            case .success:
                let logoutAlertAction = UIAlertAction(title: "확인", style: .default) { _ in
                    RegisterUserInfo.shared.loginState = false
                }
                let logoutAlert = UIAlertController(title: "로그아웃", message: "로그아웃되어 로그인페이지로 이동됩니다.", preferredStyle: .alert)
                logoutAlert.addAction(logoutAlertAction)
                self.present(logoutAlert, animated: true)
                
            case .failure(let error):
                print(#fileID, #function, #line, "- fail: \(error)")
            }
        }
    }
    
    //MARK: - 회원탈퇴
    func requestWithdraw() {
        UserNetwork.shared.withDraw { result in
            switch result {
            case .success(let success):
                print(#fileID, #function, #line, "- sucess")
                let withdrawAlertAction = UIAlertAction(title: "확인", style: .default)  { _ in
                    UserDefaults.standard.removeObject(forKey: "isFirstTime")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    RegisterUserInfo.shared.userAccessToken = ""
                    RegisterUserInfo.shared.loginState = false
                    RegisterUserInfo.shared.nickName = ""
                }
                let withdrawAlert = UIAlertController(title: "회원탈퇴", message: "회원탈퇴되어 로그인페이지로 이동됩니다.", preferredStyle: .alert)
                withdrawAlert.addAction(withdrawAlertAction)
                self.present(withdrawAlert, animated: true)
            case .failure(let error):
                print(#fileID, #function, #line, "- fail error: \(error)")
            }
        }
    }
    
    @objc func userDelete() {
        print(#fileID, #function, #line, "- 회원탈퇴")
        let cancelWithdrawAlertAction = UIAlertAction(title: "취소", style: .cancel)
        let okayWithdrawAlertAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.requestWithdraw()
        }
        
        let askWithdrawAlert = UIAlertController(title: "정말 회원탈퇴를 하시겠습니까?", message: "회원탈퇴를 하시면 데이터를 복원할 수 없습니다!", preferredStyle: .alert)
        askWithdrawAlert.addAction(cancelWithdrawAlertAction)
        askWithdrawAlert.addAction(okayWithdrawAlertAction)
        self.present(askWithdrawAlert, animated: true)
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
        [changeProfileAndNicknameLabel, changeProfileAndNicknameButton, userDeleteLabel, userDeleteButton, changeJobLabel, changeJobButton, logoutLabel, logoutButton].forEach({view.addSubview($0)})
        
        changeProfileAndNicknameLabel.snp.makeConstraints({
            $0.top.equalTo(job.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        changeProfileAndNicknameButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.changeProfileAndNicknameLabel.snp.centerY)
            $0.width.height.equalTo(25)
        })
        
        changeJobLabel.snp.makeConstraints({
            $0.top.equalTo(changeProfileAndNicknameLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        changeJobButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.changeJobLabel.snp.centerY)
            $0.width.height.equalTo(25)
        })
        
        logoutLabel.snp.makeConstraints({
            $0.top.equalTo(changeJobLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        logoutButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.logoutLabel.snp.centerY)
            $0.width.height.equalTo(25)
        })
        
        userDeleteLabel.snp.makeConstraints({
            $0.top.equalTo(logoutLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        userDeleteButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(self.userDeleteLabel.snp.centerY)
            $0.width.height.equalTo(25)
        })
    }
    
}
