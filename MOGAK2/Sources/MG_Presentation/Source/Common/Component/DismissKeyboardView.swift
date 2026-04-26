//
//  File.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/29.
//

import UIKit

class DismissKeyboardView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
}
