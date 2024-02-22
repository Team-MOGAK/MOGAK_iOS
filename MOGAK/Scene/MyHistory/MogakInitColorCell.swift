//
//  MogakInitColorCell.swift
//  MOGAK
//
//  Created by 이재혁 on 11/26/23.
//

import UIKit
import SnapKit

class MogakInitColorCell: UICollectionViewCell {
    static let identifier = "MogakInitColorCell"
        var color: UIColor!
        
        var colorView: UIView!
        var innerView: UIView!
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            configureLayout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        //MARK: - 뷰들 레이아웃 잡기
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
        
        //MARK: - 컬러차트에 색 넣어주기
        func setUpColorView() {
            colorView.backgroundColor = self.color
            colorView.layer.cornerRadius = 20 //width가 40이니까 그거의 절반인 20으로만들기
            colorView.clipsToBounds = true
            colorView.snp.makeConstraints { make in
                make.size.equalTo(40)
            }
        }
        
        //MARK: - 해당 컬러 차트가 선택되었다는 걸 표시할 ColorView의 내부 뷰
        func setUpInnerView() {
            innerView.backgroundColor = .clear
            innerView.layer.cornerRadius = 12
            innerView.clipsToBounds = true
            innerView.snp.makeConstraints { make in
                make.size.equalTo(24)
            }
        }
        
        //MARK: - 컬러차트가 선택됬음
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    innerView.backgroundColor = DesignSystemColor.white.value
    //                NotificationCenter.default.post(name: Notification.Name.colorSetting, object: nil, userInfo: [SetModalartState.modalartColor : true])
                } else {
                    innerView.backgroundColor = .clear
                }
            }
        }
}
