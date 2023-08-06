//
//  ViewController1.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import UIKit
import SnapKit

class OnBoardingFirstViewController: UIViewController {
    
    private let titleLabel = UILabel().then {
        $0.text = "가장 자극받을 수 있는\n게시물을\n매일 추천해드려요."
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.font = UIFont.pretendard(.medium, size: 30)
        $0.asFont(targetString: "가장 자극받을 수 있는", font: UIFont.pretendard(.semiBold, size: 30))
    }
    
    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding1")
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
