//
//  ButtonWithMenu.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/27.
//

import UIKit

class ButtonWithMenu: UIButton {
    var offset = CGPoint.zero
    override func menuAttachmentPoint(for configuration: UIContextMenuConfiguration) -> CGPoint {
        let original = super.menuAttachmentPoint(for: configuration)
        return CGPoint(x: original.x + offset.x, y: original.y + offset.y)
    }
}


