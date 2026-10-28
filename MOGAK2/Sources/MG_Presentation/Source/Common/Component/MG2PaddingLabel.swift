//
//  MG2PaddingLabel.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/09.
//

import UIKit

/// 안쪽 여백이 있는 라벨. 크기 계산 · 줄바꿈 · 끝 줄임(…)도 여백 안쪽 기준이다.
class MG2PaddingLabel: UILabel {
    var topInset: CGFloat
    var bottomInset: CGFloat
    var leftInset: CGFloat
    var rightInset: CGFloat

    init(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
        topInset = top
        bottomInset = bottom
        leftInset = left
        rightInset = right
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        let rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        return rect.inset(by: UIEdgeInsets(top: -topInset, left: -leftInset, bottom: -bottomInset, right: -rightInset))
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)))
    }
}
