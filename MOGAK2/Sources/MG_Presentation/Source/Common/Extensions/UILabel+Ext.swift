//
//  UILabel+Ext.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/05.
//

import UIKit

extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat) {
        guard let text else { return }
        let attributedText = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attributedText.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedText.length)
        )
        self.attributedText = attributedText
    }

    func asFont(targetString: String, font: UIFont) {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: targetString)
        attributedString.addAttribute(.font, value: font, range: range)
        attributedText = attributedString
    }
    
    func asFontColor(targetString: String, font: UIFont?, color: UIColor?) {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: targetString)
        attributedString.addAttributes([.font: font as Any, .foregroundColor: color as Any], range: range)
        attributedText = attributedString
    }
}
