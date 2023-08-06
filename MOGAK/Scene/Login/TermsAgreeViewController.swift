//
//  TermsAgreeViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import UIKit
import SnapKit

class TermsAgreeViewController: UIViewController {
    
    private var allAgreeIsOn = false
    private var ageIsOn = false
    private var serviceIsOn = false
    private var privacyIsOn = false
    private var marketingIsOn = false
    
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "서비스 이용 동의"
        label.font = UIFont.pretendard(.bold, size: 24)
        return label
    }()
    
    private lazy var permAllAgreeButton = UIButton().then {
        $0.setImage(UIImage(named: "checkOff"), for: .normal)
        $0.addTarget(self, action: #selector(allAgreeTapped), for: .touchUpInside)
    }
    
    private let permAllLabel = UILabel().then {
        $0.text = "약관 전체 동의"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.semiBold, size: 18)
    }
    
    private let permAllSubLabel = UILabel().then {
        $0.text = "서비스 이용을 위해 약관에 모두 동의합니다."
        $0.textColor = UIColor(hex: "BFC3D4")
        $0.font = UIFont.pretendard(.medium, size: 14)
    }
    
    private let permUnderline = UIView().then {
        $0.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        $0.layer.borderWidth = 1
    }
    
    // 만 14세
    private lazy var ageButton = UIButton().then {
        $0.setImage(UIImage(named: "checkOff"), for: .normal)
        $0.addTarget(self, action: #selector(ageTapped), for: .touchUpInside)
    }
    
    private let ageLabel = UILabel().then {
        $0.text = "(필수) 만 14세입니다."
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.regular, size: 16)
    }
    
    // 서비스 이용약관
    private lazy var serviceButton = UIButton().then {
        $0.setImage(UIImage(named: "checkOff"), for: .normal)
        $0.addTarget(self, action: #selector(serviceTapped), for: .touchUpInside)
    }
    
    private let serviceLabel = UILabel().then {
        $0.text = "(필수) 서비스 이용악관"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.regular, size: 16)
    }
    
    private let serviceNext = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "808497")
    }
    
    // 개인정보 처리방침
    private lazy var privacyButton = UIButton().then {
        $0.setImage(UIImage(named: "checkOff"), for: .normal)
        $0.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
    }
    
    private let privacyLabel = UILabel().then {
        $0.text = "(필수) 개인정보 처리방침"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.regular, size: 16)
    }
    
    private let privacyNext = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "808497")
    }
    
    // 마케팅 정보 수신동의
    private lazy var marketingButton = UIButton().then {
        $0.setImage(UIImage(named: "checkOff"), for: .normal)
        $0.addTarget(self, action: #selector(marketingTapped), for: .touchUpInside)
    }
    
    private let marketingLabel = UILabel().then {
        $0.text = "(선택) 마케팅 정보 수신동의"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.regular, size: 16)
    }
    
    private let marketingNext = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = UIColor(hex: "808497")
    }
    
    private lazy var nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(UIColor(hex: "ffffff"), for: .normal)
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor(hex: "BFC3D4")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(nextButtonIsClicked), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        self.configureNavBar()
        self.configureLabel()
        self.configureTerm()
        self.configureButton()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubview(mogakLabel)
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(20)
        })
        
    }
    
    private func configureTerm() {
        self.view.addSubviews(permAllAgreeButton, permAllLabel, permAllSubLabel, permUnderline)
        
        [ageButton, ageLabel, serviceButton, serviceLabel, serviceNext, privacyButton, privacyLabel, privacyNext, marketingButton, marketingLabel, marketingNext].forEach({view.addSubview($0)})
        
        permAllAgreeButton.snp.makeConstraints({
            $0.top.equalTo(self.mogakLabel.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalToSuperview().multipliedBy(0.053)
            $0.height.equalTo(self.permAllAgreeButton.snp.width)
        })
        
        permAllLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.permAllAgreeButton.snp.centerY)
            $0.leading.equalTo(self.permAllAgreeButton.snp.trailing).offset(12)
        })
        
        permAllSubLabel.snp.makeConstraints({
            $0.top.equalTo(self.permAllLabel.snp.bottom).offset(9)
            $0.leading.equalTo(self.permAllAgreeButton.snp.trailing).offset(12)
        })
        
        permUnderline.snp.makeConstraints({
            $0.top.equalTo(self.permAllSubLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        })
        
        ageButton.snp.makeConstraints({
            $0.top.equalTo(self.permUnderline.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalToSuperview().multipliedBy(0.053)
            $0.height.equalTo(self.ageButton.snp.width)
        })
        
        ageLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.ageButton.snp.centerY)
            $0.leading.equalTo(self.ageButton.snp.trailing).offset(12)
        })
        
        serviceButton.snp.makeConstraints({
            $0.top.equalTo(self.ageButton.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalToSuperview().multipliedBy(0.053)
            $0.height.equalTo(self.serviceButton.snp.width)
        })
        
        serviceLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.serviceButton.snp.centerY)
            $0.leading.equalTo(self.serviceButton.snp.trailing).offset(12)
        })
        
        serviceNext.snp.makeConstraints({
            $0.centerY.equalTo(self.serviceButton.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalToSuperview().multipliedBy(0.041)
            $0.height.equalTo(self.serviceButton.snp.width)
        })
        
        privacyButton.snp.makeConstraints({
            $0.top.equalTo(self.serviceButton.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalToSuperview().multipliedBy(0.053)
            $0.height.equalTo(self.privacyButton.snp.width)
        })
        
        privacyLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.privacyButton.snp.centerY)
            $0.leading.equalTo(self.privacyButton.snp.trailing).offset(12)
        })
        
        privacyNext.snp.makeConstraints({
            $0.centerY.equalTo(self.privacyButton.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalToSuperview().multipliedBy(0.041)
            $0.height.equalTo(self.privacyButton.snp.width)
        })
        
        marketingButton.snp.makeConstraints({
            $0.top.equalTo(self.privacyButton.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalToSuperview().multipliedBy(0.053)
            $0.height.equalTo(self.marketingButton.snp.width)
        })
        
        marketingLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.marketingButton.snp.centerY)
            $0.leading.equalTo(self.marketingButton.snp.trailing).offset(12)
        })
        
        marketingNext.snp.makeConstraints({
            $0.centerY.equalTo(self.marketingButton.snp.centerY)
            $0.trailing.equalToSuperview().offset(-30)
            $0.width.equalToSuperview().multipliedBy(0.041)
            $0.height.equalTo(self.marketingButton.snp.width)
        })
        
    }
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            //            $0.height.equalTo(53)
            $0.height.equalToSuperview().multipliedBy(0.061)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        })
    }
    
    private func nextIsConfirm() {
        let isOn = ageIsOn && serviceIsOn && privacyIsOn
        if isOn {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = UIColor(hex: "475FFD")
//            permAllAgreeButton.setImage(UIImage(named: "checkOn"), for: .normal)
        } else {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = UIColor(hex: "BFC3D4")
//            permAllAgreeButton.setImage(UIImage(named: "checkOff"), for: .normal)
        }
    }
    
    // MARK: - objc
    
    @objc private func nextButtonIsClicked() {
        let nicknameVC = NicknameViewController()
        self.navigationController?.pushViewController(nicknameVC, animated: true)
    }
    
    @objc private func allAgreeTapped() {
        if allAgreeIsOn {
            [permAllAgreeButton, ageButton, privacyButton, marketingButton, serviceButton].forEach({$0.setImage(UIImage(named: "checkOff"), for: .normal)})
            allAgreeIsOn = false
            ageIsOn = false
            privacyIsOn = false
            marketingIsOn = false
            serviceIsOn = false
            nextIsConfirm()
        } else {
            [permAllAgreeButton, ageButton, privacyButton, marketingButton, serviceButton].forEach({$0.setImage(UIImage(named: "checkOn"), for: .normal)})
            allAgreeIsOn = true
            allAgreeIsOn = true
            ageIsOn = true
            privacyIsOn = true
            marketingIsOn = true
            serviceIsOn = true
            nextIsConfirm()
        }
    }
    
    @objc private func ageTapped() {
        if ageIsOn {
            ageButton.setImage(UIImage(named: "checkOff"), for: .normal)
            ageIsOn = false
            nextIsConfirm()
        } else {
            ageButton.setImage(UIImage(named: "checkOn"), for: .normal)
            ageIsOn = true
            nextIsConfirm()
        }
    }
    
    @objc private func serviceTapped() {
        if serviceIsOn {
            serviceButton.setImage(UIImage(named: "checkOff"), for: .normal)
            serviceIsOn = false
            nextIsConfirm()
        } else {
            serviceButton.setImage(UIImage(named: "checkOn"), for: .normal)
            serviceIsOn = true
            nextIsConfirm()
        }
    }
    
    @objc private func privacyTapped() {
        if privacyIsOn {
            privacyButton.setImage(UIImage(named: "checkOff"), for: .normal)
            privacyIsOn = false
            nextIsConfirm()
        } else {
            privacyButton.setImage(UIImage(named: "checkOn"), for: .normal)
            privacyIsOn = true
            nextIsConfirm()
        }
    }
    
    @objc private func marketingTapped() {
        if marketingIsOn {
            marketingButton.setImage(UIImage(named: "checkOff"), for: .normal)
            marketingIsOn = false
            nextIsConfirm()
        } else {
            marketingButton.setImage(UIImage(named: "checkOn"), for: .normal)
            marketingIsOn = true
            nextIsConfirm()
        }
        
    }
    
}
