//
//  UIColor+Ext.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        guard hexFormatted.count == 6,
              let rgbValue = UInt64(hexFormatted, radix: 16) else {
            self.init(white: 0, alpha: 1)
            return
        }
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: 1.0)
    }
}
