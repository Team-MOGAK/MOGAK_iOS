//
//  CertificationModalVC.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/14.
//

import UIKit
import SnapKit
import Then

class CertificationModalVC : UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    private lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "조각을 시작하기 전에\n 내 실천 인증 사진을 남겨주세요."
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(hex: "24252E")
        return titleLabel
    }()
    
    private lazy var subtitleLabel : UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.text = "인증 사진을 찍지 않으면 조각을 시작할 수 없어요"
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont(name: "Pretendard", size: 14)
        subtitleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        return subtitleLabel
    }()
    
    private lazy var buttonView : UIView = {
        let buttonView = UIView()
        buttonView.backgroundColor = UIColor(red: 0.947, green: 0.953, blue: 0.979, alpha: 1)
        buttonView.layer.cornerRadius = 10
        return buttonView
    }()
    
    
    private lazy var stopButton : UIButton = {
        let stopButton = UIButton()
        stopButton.setTitle("좋아요!",for : .normal) //타이틀
        stopButton.setTitleColor(.white, for : .normal) //글자 색
        stopButton.backgroundColor = UIColor(hex: "475FFD") //백그라운드색
        stopButton.layer.cornerRadius = 10 //둥글기
        stopButton.addTarget(self, action: #selector(scheduleRecord), for: .touchUpInside)
        return stopButton
    }()
    
    private lazy var keepGoButton : UIButton = {
        let keepGoButton = UIButton()
        keepGoButton.setTitle("괜찮아요",for : .normal) //타이틀
        keepGoButton.setTitleColor(UIColor(hex: "475FFD"), for: .normal) //글자 색
        keepGoButton.backgroundColor = UIColor(hex: "#E8EBFE") //백그라운드색
        keepGoButton.layer.cornerRadius = 10 //둥글기
        keepGoButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        return keepGoButton
    }()
    
    private lazy var calendarImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "calendar")
        return image
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
    }
    
    //MARK: - setUI
    func setUI(){
        [titleLabel,subtitleLabel,buttonView,stopButton,keepGoButton,calendarImage].forEach{view.addSubview($0)}
        titleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(48)
        }
        
        subtitleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        buttonView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.bottom.equalTo(stopButton.snp.top).offset(-34)
        }
        
        stopButton.snp.makeConstraints{ //좋아요
            $0.width.equalTo(170)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(20)
        }
        keepGoButton.snp.makeConstraints{ //괜찮아요
            $0.width.equalTo(170)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(20)
        }
        calendarImage.snp.makeConstraints{
            $0.centerX.centerY.equalTo(buttonView)
            $0.top.equalTo(buttonView).offset(15)
            $0.leading.equalTo(buttonView).offset(85)
            $0.trailing.equalTo(buttonView).offset(-68)
        }
    }
    
    //MARK: - @objc func
    
    @objc func scheduleRecord(){
        self.dismiss(animated: true) {
            
            let newVC = RecordingViewController()
            newVC.modalPresentationStyle = .fullScreen
            
            if let RecordingVC = UIApplication.shared.keyWindow?.rootViewController {
                RecordingVC.present(newVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func dismissModal(){
        self.dismiss(animated: true){[weak self] in
            guard self != nil else { return }
            
            let scheduleVC = ScheduleStartViewController()
            
            scheduleVC.showToast(message: "오늘 한 일이 추가되었습니다.", font: DesignSystemFont.regular14L150.value)
            
        }
    }
}
