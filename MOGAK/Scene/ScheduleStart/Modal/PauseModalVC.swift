//
//  PauseModalVC.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/11.
//

import UIKit
import SnapKit
import Then

class PauseModalVC : UIViewController,UISheetPresentationControllerDelegate{
    
    private lazy var canceltitleLabel : UILabel = {
        let canceltitleLabel = UILabel()
        canceltitleLabel.text = "조각을 완성하시겠습니까?"
        canceltitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        canceltitleLabel.textColor = UIColor(hex: "24252E")
        return canceltitleLabel
    }()
    
    private lazy var cancelsubtitleLabel : UILabel = {
        let cancelsubtitleLabel = UILabel()
        cancelsubtitleLabel.text = "오늘도 수고하셨어요!\n 나와의 약속을 지킨 당신을 응원해요"
        cancelsubtitleLabel.numberOfLines = 2
        cancelsubtitleLabel.textAlignment = .center
        cancelsubtitleLabel.font = UIFont(name: "Pretendard", size: 14)
        cancelsubtitleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        return cancelsubtitleLabel
    }()
    
    private lazy var stopButton : UIButton = {
        let stopButton = UIButton()
        stopButton.setTitle("완성하기",for : .normal) //타이틀
        stopButton.setTitleColor(.white, for : .normal) //글자 색
        stopButton.backgroundColor = UIColor(hex: "475FFD") //백그라운드색
        stopButton.layer.cornerRadius = 10 //둥글기
        stopButton.addTarget(self, action: #selector(ScheduleStop), for: .touchUpInside)
        return stopButton
    }()
    
    private lazy var keepGoButton : UIButton = {
        let keepGoButton = UIButton()
        keepGoButton.setTitle("아니요",for : .normal) //타이틀
        keepGoButton.setTitleColor(UIColor(hex: "475FFD"), for: .normal) //글자 색
        keepGoButton.backgroundColor = UIColor(hex: "#E8EBFE") //백그라운드색
        keepGoButton.layer.cornerRadius = 10 //둥글기
        keepGoButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        return keepGoButton
    }()
    
    var circularProgressView = CircularProgressView()
    var onClick : (() -> ())?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        circularProgressView.isHidden = true
        
    }
    
    //MARK: - setUI
    func setUI(){
        [canceltitleLabel,cancelsubtitleLabel,stopButton,keepGoButton,circularProgressView].forEach{view.addSubview($0)}
        canceltitleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(49)
        }
        
        cancelsubtitleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(canceltitleLabel.snp.bottom).offset(12)
        }
        
        stopButton.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(200)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().inset(24)
            $0.trailing.equalToSuperview().inset(20)
        }
        keepGoButton.snp.makeConstraints{ 
            $0.trailing.equalToSuperview().inset(200)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(20)
            
        }
    }
    //MARK: - @objc func
    
    @objc func ScheduleStop(){
        print("ScheduleStop")
        self.dismiss(animated: true, completion: {
            self.onClick?()
        })
    }
    @objc func dismissModal(){
        self.dismiss(animated: true){ [self] in
            circularProgressView.resumeTimer()
        }
    }
}

