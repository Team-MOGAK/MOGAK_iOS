//
//  MyPageViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/07.
//

import UIKit
import SnapKit
import Then
import WebKit

enum WebUrl: String {
    case noti = "https://www.google.com" //공지사항
    case ask = "https://www.naver.com" //문의사항
    case perm = "https://mogak.oopy.io/fbb05a84-baec-4a8a-87dc-ec42d2a7955d"
    case privacy = "https://mogak.oopy.io/4ac04bef-8493-4108-b9f9-6c6250155948" //개인정보 처리방침
}

class MyPageViewController: UIViewController, WKUIDelegate, UIGestureRecognizerDelegate {
    private lazy var profileView : UIView = {
        let uiview = UIView()
        uiview.backgroundColor = DesignSystemColor.signature.value
        return uiview
    }()
    
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
        $0.textColor = UIColor.white
    }
    
    private let job = UILabel().then {
        $0.text = "서비스기획자/PM"
        $0.font = UIFont.pretendard(.medium, size: 12)
        $0.textColor = UIColor.white
    }
    
    private lazy var editButton = UIButton().then {
        $0.setTitle("프로필 수정", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = UIColor(hex: "6C7FFD")
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 16)
        $0.titleLabel?.textAlignment = .center
        $0.layer.cornerRadius = 10
        $0.addTarget(self, action: #selector(goToEditPage), for: .touchUpInside)
    }
    
    private let shareButton = UIButton().then {
        $0.setTitle("프로필 공유", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = UIColor(hex: "6C7FFD")
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
    
    //MARK: - 푸시알림
    private lazy var pushView: UIStackView = UIStackView()
    
    private let pushLabel = UILabel().then {
        $0.text = "푸시 알림 설정"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private lazy var pushLeftArrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.contentMode = .scaleAspectFill
        $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    //MARK: - 공지사항
    private lazy var notiView : UIStackView = UIStackView()
    
    private lazy var notiLabel = UILabel().then {
        $0.text = "공지사항"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private lazy var notiLeftArrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.contentMode = .scaleAspectFill
        $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    //MARK: - 문의하기
    private lazy var askView: UIStackView = UIStackView()
    
    private let askLabel = UILabel().then {
        $0.text = "문의하기"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private lazy var askLeftArrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.contentMode = .scaleAspectFill
        $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    //MARK: - 이용약관
//    private lazy var permView: UIView = UIView()
    private let permView: UIStackView = {
       let stk = UIStackView()
        return stk
    }()
    
    private let permLabel = UILabel().then {
        $0.text = "이용약관"
        $0.isUserInteractionEnabled = true
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private lazy var permLeftArrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.contentMode = .scaleAspectFill
        $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    //MARK: - 개인정보 처리방침
    private lazy var privacyView: UIStackView = UIStackView()
    
    private let privacyLabel = UILabel().then {
        $0.text = "개인정보 처리방침"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private lazy var privacyLeftArrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.contentMode = .scaleAspectFill
        $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    //MARK: - 위치 서비스 이용동의
    private let gpsLabel = UILabel().then {
        $0.text = "위치 서비스 이용동의"
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let gpsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "24252E")
    }
    
    //MARK: - 버전정보
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
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystemColor.signatureBag.value
        self.viewsSetting()
        self.configureProfile()
        self.configureSetting()
        self.viewConnectGestureSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false ///탭바 설정
    }
    
    //MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true ///탭바 설정
    }
    
    //MARK: - viewDidLayoutSubViews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
    }
    
    
    //MARK: - viewsSetting -> 공지사항, 문의사항 뷰에 라벨이랑 화살표 넣기
    func viewsSetting() {
        self.profileView.addSubviews(profileImage, name, job, buttonStackView)
        
        self.pushView.addArrangedSubview(pushLabel)
        self.pushView.addArrangedSubview(pushLeftArrow)
        self.notiView.addArrangedSubview(notiLabel)
        self.notiView.addArrangedSubview(notiLeftArrow)
        self.askView.addArrangedSubview(askLabel)
        self.askView.addArrangedSubview(askLeftArrow)
        self.permView.addArrangedSubview(permLabel)
        self.permView.addArrangedSubview(permLeftArrow)
        self.privacyView.addArrangedSubview(privacyLabel)
        self.privacyView.addArrangedSubview(privacyLeftArrow)
    }
    
    //MARK: - 각 view에 제스처 넣어주기
    func viewConnectGestureSetting() {
        print(#fileID, #function, #line, "- 제스처 연결?")
        let notiGesture = UITapGestureRecognizer(target: self, action: #selector(self.notiTappedAction(_:)))
        self.notiView.addGestureRecognizer(notiGesture)
        
        let askGesture = UITapGestureRecognizer(target: self, action:  #selector(self.askTappedAction(_:)))
        self.askView.addGestureRecognizer(askGesture)
        
        let permGesture = UITapGestureRecognizer(target: self, action: #selector(self.permTappedAction(_:)))
        self.permView.addGestureRecognizer(permGesture)
        
        let privacyGesture = UITapGestureRecognizer(target: self, action: #selector(self.privacyTappedAction(_:)))
        self.privacyView.addGestureRecognizer(privacyGesture)
    }
    
    //MARK: - 프로필 수정 뷰로 이동
    @objc private func goToEditPage() {
        let mypageVC = MyPageEditViewController()
        self.navigationController?.pushViewController(mypageVC, animated: true)
    }
    
    //MARK: - 공지사항 알림 동의
    @objc func notiTappedAction(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- 이용약관 뷰 클릭")
        let webViewVC = MypageWebViewController()
        webViewVC.url = .noti
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    //MARK: - 문의사항 알림 동의
    @objc func askTappedAction(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- 이용약관 뷰 클릭")
        let webViewVC = MypageWebViewController()
        webViewVC.url = .ask
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    //MARK: - 이용약관 알림 동의
    @objc func permTappedAction(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- 이용약관 뷰 클릭")
        let webViewVC = MypageWebViewController()
        webViewVC.url = .perm
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    //MARK: - 개인정보 알림 동의
    @objc func privacyTappedAction(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- 개인정보 뷰 클릭")
        let webViewVC = MypageWebViewController()
        webViewVC.url = .privacy
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
}


extension MyPageViewController {
    //MARK: - 프로필 레이아웃 설정
    private func configureProfile() {
        self.view.addSubview(profileView)
        self.profileView.addSubviews(profileImage, name, job, buttonStackView)
        
        [editButton, shareButton].forEach( {buttonStackView.addArrangedSubview($0)} )
        profileView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        profileImage.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(73)
        })
        
        name.snp.makeConstraints({
            $0.top.equalTo(self.profileImage.snp.top).offset(10)
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(11)
        })
        
        job.snp.makeConstraints({
            $0.top.equalTo(self.name.snp.bottom).offset(8)
            $0.leading.equalTo(self.profileImage.snp.trailing).offset(11)
        })
        
        buttonStackView.snp.makeConstraints({
            $0.top.equalTo(self.profileImage.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalTo(profileView.snp.bottom).offset(-30)
        })
    }
    
    //MARK: - 기타 레이아웃 설정(공지사항, 문의사항 등)
    private func configureSetting() {
        self.view.addSubviews(pushView, notiView, askView, permView, privacyView)
        self.view.addSubviews(gpsLabel, gpsButton, versionLabel, versionNumberLabel)
        
        ///푸시알림
        pushView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.profileView.snp.bottom).offset(32)
            make.height.equalTo(22)
        }

        ///공지사항
        notiView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.pushLabel.snp.bottom).offset(32)
            make.height.equalTo(22)
        }

        ///문의사항
        askView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.notiLabel.snp.bottom).offset(32)
            make.height.equalTo(22)
        }
        
        ///이용약관
        permView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.askLabel.snp.bottom).offset(32)
            make.height.equalTo(22)
        }
        
        ///개인정보처리방침
        privacyView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.permLabel.snp.bottom).offset(32)
            make.height.equalTo(22)
        }
        
        ///위치정보 동의설정
        gpsLabel.snp.makeConstraints({
            $0.top.equalTo(self.privacyLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(30)
        })
        
        gpsButton.snp.makeConstraints({
            $0.centerY.equalTo(self.gpsLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.height.equalTo(16)
        })
        
        ///버전정보
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

//MARK: - 제스처 설정
extension MyPageViewController {
    
}
