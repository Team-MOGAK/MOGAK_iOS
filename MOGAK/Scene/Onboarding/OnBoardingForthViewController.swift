//
//  OnBoardingForthViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/27.
//

import Foundation
import SnapKit

#if false
// Legacy MOGAK1 implementation (inactive after 1:1 migration to MG_Presentation).
class OnBoardingForthViewController: UIViewController {
    
    private let titleLabel = UILabel().then {
        $0.text = "세부 목표를 이루기 위한 \n세부 행동 8가지를 정하고, \n습관으로 만들어보세요"
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.pretendard(.regular, size: 28)
        $0.asFont(targetString: "\n세부 행동 8가지를 정하고, \n습관으로 만들어보세요", font: UIFont.pretendard(.semiBold, size: 28))
    }
    
    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding4")
        $0.contentMode = .scaleAspectFit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = DesignSystemColor.gray2.value
//        view.backgroundColor = UIColor.white
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
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(24)
//            $0.leading.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        })
    }
    
}

