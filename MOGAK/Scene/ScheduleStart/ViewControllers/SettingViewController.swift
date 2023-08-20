//
//  ProfileViewController.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/02.
//

import UIKit
import SnapKit
import Then

class SettingViewController : UIViewController, UISheetPresentationControllerDelegate{  //지워주기
    
    private lazy var popButton : UIButton = {
        let popButton = UIButton()
        popButton.backgroundColor = .clear //백그라운드색
        popButton.setImage(UIImage(named: "backButton_black"), for: .normal)
        popButton.addTarget(self, action: #selector(backhome), for: .touchUpInside)
        return popButton
    }()
    
    private lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "내 설정"
        titleLabel.textColor = UIColor(hex: "24252E")
        titleLabel.font = UIFont(name: "Pretendard", size: 18)
        return titleLabel
    }()

    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
    }
    
    @objc func backhome(){
        lazy var homeVC = ScheduleStartViewController()
        navigationController?.popViewController(animated: true)
        
        print("back profile")
    }
    
   func setUI(){
       [popButton,titleLabel].forEach{view.addSubview($0)}
       
       popButton.snp.makeConstraints{
           $0.top.equalTo(view.safeAreaLayoutGuide)//.offset(6)
           $0.height.width.equalTo(24)
           $0.leading.equalToSuperview().inset(20)
       }
       titleLabel.snp.makeConstraints{
           $0.centerX.equalToSuperview()
           $0.centerY.equalTo(popButton)
       }
    }
}


