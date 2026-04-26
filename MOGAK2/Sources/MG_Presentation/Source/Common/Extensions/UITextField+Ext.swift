//
//  UITextField+Ext.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/13.
//

import UIKit

extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    
    func addRightImage(image:UIImage) {
        let rightimage = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        rightimage.image = image
        self.rightView = rightimage
        self.rightViewMode = .always
    }
    
    //MARK: - placeHolderColor설정하기
    //반드시 string넣고 -> color지정
    func setPlaceholderColor(_ placeHolderColor: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeHolderColor,
                .font: font
            ].compactMapValues{ $0 }
        )
    }
}
