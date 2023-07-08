//
//  ViewController3.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/08.
//

import UIKit
import SnapKit
import Then

class ViewController3: UIViewController {
    
    private let titleLabel = UILabel().then {
        $0.text = "모두가 각자의 성장을\n응원해봐요"
        $0.font = UIFont.pretendard(.regular, size: 32)
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .systemBlue
        view.addSubviews(titleLabel)
        self.changeLabelFont()
        self.configureUI()
    }
    
    private func changeLabelFont() {
        guard let text = self.titleLabel.text else {return}
        let attributeString = NSMutableAttributedString(string: text)
        let font = UIFont.pretendard(.bold, size: 32)
        attributeString.addAttribute(.font, value: font, range: (text as NSString).range(of: "모두가 각자의 성장"))
        self.titleLabel.attributedText = attributeString
    }
    
    private func configureUI() {
        self.configureTitle()
    }
    
    private func configureTitle() {
        titleLabel.snp.makeConstraints {make in
            make.top.equalTo(view).offset(116)
            make.leading.equalTo(view).offset(28)
        }
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
