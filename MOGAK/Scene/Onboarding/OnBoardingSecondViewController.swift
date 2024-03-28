//
//  ViewController2.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import UIKit
import SnapKit

class OnBoardingSecondViewController: UIViewController {
    
    private let titleLabel = UILabel().then {
        $0.text = "만다라트 기법을 통해 \n목표를 달성하기 위한 \n세부 목표를 구체화하세요."
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.font = UIFont.pretendard(.regular, size: 28)
        $0.textAlignment = .center
        $0.asFont(targetString: "만다라트 기법을 통해", font: UIFont.pretendard(.semiBold, size: 30))
    }
    
    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding2")
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
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(32)
//            $0.leading.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        })
    }
    
}


#if DEBUG
import SwiftUI
struct Preview2: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        OnBoardingSecondViewController()
    }
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct ViewController_PreviewProvider2: PreviewProvider {
    static var previews: some View {
        Group {
            Preview2()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
        }
    }
}
#endif
