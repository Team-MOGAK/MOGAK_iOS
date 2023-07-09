//
//  TermsAgreeViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import UIKit
import SnapKit

class TermsAgreeViewController: UIViewController {
    
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAK"
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    private let titleTermLabel : UILabel = {
        let label = UILabel()
        label.text = "이용약관동의"
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    private let subLabel : UILabel = {
        let label = UILabel()
        label.text = "모각러들과 함께하기 위해서는 이용약관 동의가 필요합니다."
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    // MARK: - 이용약관동의
    
    private lazy var termStackButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let termStackLabel : UILabel = {
        let label = UILabel()
        label.text = "이용약관동의"
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    private lazy var termStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [termStackButton, termStackLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()
    
    private let termLinkLabel : UILabel = {
        let label = UILabel()
        label.text = "보기"
        label.font = UIFont.pretendard(.bold, size: 15)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - 푸시알림동의
    
    private lazy var pushStackButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let pushStackLabel : UILabel = {
        let label = UILabel()
        label.text = "푸시알림동의"
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    private lazy var pushStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pushStackButton, pushStackLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()
    
    private let pushLinkLabel : UILabel = {
        let label = UILabel()
        label.text = "보기"
        label.font = UIFont.pretendard(.bold, size: 15)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - 개인정보처리방침

    private lazy var privacyStackButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let privacyStackLabel : UILabel = {
        let label = UILabel()
        label.text = "개인정보처리방침"
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    private lazy var privacyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [privacyStackButton, privacyStackLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()
    
    private let privacyLinkLabel : UILabel = {
        let label = UILabel()
        label.text = "보기"
        label.font = UIFont.pretendard(.bold, size: 15)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - 위치서비스약관

    private lazy var gpsStackButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let gpsStackLabel : UILabel = {
        let label = UILabel()
        label.text = "위치서비스약관"
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    private lazy var gpsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [gpsStackButton, gpsStackLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()
    
    private let gpsLinkLabel : UILabel = {
        let label = UILabel()
        label.text = "보기"
        label.font = UIFont.pretendard(.bold, size: 15)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - 라인 + 전체동의

    private let lineView : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var wholeStackButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let wholeStackLabel : UILabel = {
        let label = UILabel()
        label.text = "전체동의"
        label.font = UIFont.pretendard(.bold, size: 15)
        return label
    }()
    
    private lazy var wholeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [wholeStackButton, wholeStackLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        return stackView
    }()
    
    private let nextButton : UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.textColor = .white
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.configureNavBar()
        self.configureLabel()
        self.configureTerm()
        self.configurePush()
        self.configurePrivacy()
        self.configureGPS()
        self.configureWhole()
        self.configureButton()
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .gray
    }
    
    private func configureLabel() {
        self.view.addSubviews(mogakLabel, titleTermLabel, subLabel)
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            $0.leading.equalToSuperview().offset(21)
        })
        
        titleTermLabel.snp.makeConstraints({
            $0.top.equalTo(mogakLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(21)
        })
        
        subLabel.snp.makeConstraints({
            $0.top.equalTo(titleTermLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(21)
        })
    }
    
    private func configureTerm() {
        self.view.addSubviews(termStackView, termLinkLabel)
        
        termStackView.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(subLabel.snp.bottom).offset(117)
            $0.height.equalTo(28)
        })
        
        termLinkLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(termStackView)
        })
    }
    
    private func configurePush() {
        self.view.addSubviews(pushStackView, pushLinkLabel)
        
        pushStackView.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(termStackView.snp.bottom).offset(48)
            $0.height.equalTo(28)
        })
        
        pushLinkLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(pushStackView)
        })
    }
    
    private func configurePrivacy() {
        self.view.addSubviews(privacyStackView, privacyLinkLabel)
        
        privacyStackView.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(pushStackView.snp.bottom).offset(48)
            $0.height.equalTo(28)
        })
        
        privacyLinkLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(privacyStackView)
        })
    }
    
    private func configureGPS() {
        self.view.addSubviews(gpsStackView, gpsLinkLabel)
        
        gpsStackView.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(privacyStackView.snp.bottom).offset(48)
            $0.height.equalTo(28)
        })
        
        gpsLinkLabel.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(gpsStackView)
        })
    }
    
    private func configureWhole() {
        self.view.addSubviews(wholeStackView, lineView)
        
        lineView.snp.makeConstraints({
            $0.top.equalTo(gpsStackView.snp.bottom).offset(24)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        })
        
        wholeStackView.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(lineView.snp.bottom).offset(30)
            $0.height.equalTo(28)
        })
    }
    
    private func configureButton() {
        self.view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(53)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-53)
        })
    }
}
