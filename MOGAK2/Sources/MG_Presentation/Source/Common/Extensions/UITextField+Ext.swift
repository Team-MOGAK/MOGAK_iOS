//
//  UITextField+Ext.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/13.
//

import UIKit

extension UITextField {
    func setPlaceholderColor(_ placeHolderColor: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeHolderColor,
                .font: font
            ].compactMapValues { $0 }
        )
    }
}
