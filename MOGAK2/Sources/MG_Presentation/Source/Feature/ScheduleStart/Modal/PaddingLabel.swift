//
//  Labelpadding.swift
//  MOGAK
//
//  Created by 안세훈 on 11/26/23.
//

import UIKit

class PaddingLabel : UILabel{
    
    private var padding = UIEdgeInsets(top: 12, left: 12, bottom: 20, right: 20)
    
    convenience init(padding : UIEdgeInsets){
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize{
        var ContentSize = super.intrinsicContentSize
        ContentSize.height += padding.top + padding.bottom
        ContentSize.width += padding.left + padding.right
        
        return ContentSize
    }
    
}
