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
        $0.text = "되고 싶거나 이루고 싶은 \n목표를 설정해 \n의욕을 강화해보세요."
        $0.numberOfLines = 3
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = UIFont.pretendard(.medium, size: 28)
//        $0.asFont(targetString: "가장 자극받을 수 있는", font: UIFont.pretendard(.semiBold, size: 30))
    }
    
    private let image = UIImageView().then {
        $0.image = UIImage(named: "onboarding1")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(hex: "ffffff")
        self.view.backgroundColor = DesignSystemColor.gray2.value
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(66)
//            $0.leading.equalToSuperview().offset(35)
//            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        })
        
    }

}

#if DEBUG
import SwiftUI
struct Preview: UIViewControllerRepresentable {
    
    // 여기 ViewController를 변경해주세요
    func makeUIViewController(context: Context) -> UIViewController {
        OnBoardingFirstViewController()
    }
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
}

struct ViewController_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            Preview()
                .edgesIgnoringSafeArea(.all)
                .previewDisplayName("Preview")
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
        }
    }
}
#endif
