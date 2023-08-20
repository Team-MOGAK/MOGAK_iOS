//
//  ViewController3.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import UIKit
import Then
import SnapKit

class OnBoardingThirdViewController: UIViewController {
    
    private let titleLabel = UILabel().then {
        $0.text = "나와 같은 직무를 준비하는\n모각이들은 어떻게\n성장하는지 알수있어요!"
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.pretendard(.regular, size: 30)
        $0.asFont(targetString: "나와 같은 직무를 준비하는\n모각이", font: UIFont.pretendard(.semiBold, size: 30))
    }
    
    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding3")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "ffffff")
        configure()
    }
    
    private func configure() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(image)
        
        titleLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(64)
            $0.centerX.equalToSuperview()
        })
        
        image.snp.makeConstraints({
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(45)
            $0.width.equalToSuperview().multipliedBy(0.86)
            $0.height.equalToSuperview().multipliedBy(0.46)
            $0.centerX.equalToSuperview()
        })
    }
    
}
