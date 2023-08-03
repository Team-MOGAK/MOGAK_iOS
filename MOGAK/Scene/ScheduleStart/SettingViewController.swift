//
//  ProfileViewController.swift
//  MOGAK
//
//  Created by 안세훈 on 2023/08/02.
//

import UIKit
import SnapKit
import Then

class SettingViewController : UIViewController{
    
    private lazy var popButton : UIButton = {
        let popButton = UIButton()
        popButton.backgroundColor = .clear //백그라운드색
        popButton.setImage(UIImage(named: "<"), for: .normal)
        popButton.addTarget(self, action: #selector(backprofile), for: .touchUpInside)
        return popButton
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
    }
    
    @objc func backprofile(){
        let homeVC = ScheduleStartViewController()
        navigationController?.popViewController(animated: true)
        
        print("back profile")
    }
    
   func setUI(){
       [popButton].forEach{view.addSubview($0)}
       
       popButton.snp.makeConstraints{
           $0.top.equalTo(view.safeAreaLayoutGuide).offset(6)
           $0.leading.equalToSuperview().inset(20)
       }
    }
}
