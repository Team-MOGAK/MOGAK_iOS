//
//  ColorCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/29.
//

import UIKit
import SnapKit

class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    var color: UIColor!
    
    var colorView: UIView!
    var innerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        print(#fileID, #function, #line, "- colorcell⭐️")
        configureLayout()
//        setUpColorView()
//        setUpInnerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLayout() {
        colorView = UIView()
        innerView = UIView()
        self.addSubview(colorView)
        colorView.addSubview(innerView)
        colorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        innerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setUpColorView() {
        colorView.backgroundColor = self.color
        colorView.layer.cornerRadius = 20 //width가 40이니까 그거의 절반인 20으로만들기
        colorView.clipsToBounds = true
        colorView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
    
    func setUpInnerView() {
        innerView.backgroundColor = .clear
        innerView.layer.cornerRadius = 12
        innerView.clipsToBounds = true
        innerView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                innerView.backgroundColor = DesignSystemColor.white.value
            } else {
                innerView.backgroundColor = .clear
            }
        }
    }
}
