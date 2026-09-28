//
//  MG2DismissKeyboardView.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/29.
//

import UIKit

final class MG2DismissKeyboardView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}
