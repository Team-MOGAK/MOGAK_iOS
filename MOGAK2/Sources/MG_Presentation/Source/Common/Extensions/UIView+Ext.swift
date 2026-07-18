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

    func fadeIn(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 1 },
            completion: { _ in completion?() }
        )
    }

    func fadeOut(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 0 },
            completion: { _ in
                self.isHidden = true
                completion?()
            }
        )
    }
}
