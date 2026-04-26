//
//  UIView+Ext.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/09.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
