//
//  ViewController3.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/09.
//

import UIKit
import Then
import SnapKit

class ViewController3: UIViewController {
    
    private var titleLabel = UILabel().then {
        $0.text = "모두가 각자의 성장을\n응원해봐요"
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "f9f9f9")
        
        self.setupUI()
        self.changeFont()
    }
    
    private func setupUI() {
        self.configureLabel()
    }
    
    private func configureLabel() {
        self.view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints{ make in
            make.top.equalTo(view)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(28)
        }
    }
    
    private func changeFont() {
        guard let text = self.titleLabel.text else {return}
        let attributeString = NSMutableAttributedString(string: text)
        let font = UIFont.pretendard(.bold, size: 32)
        attributeString.addAttribute(.font, value: font, range: (text as NSString).range(of: "모두가 각자의 성장"))
        self.titleLabel.attributedText = attributeString
    }

}
