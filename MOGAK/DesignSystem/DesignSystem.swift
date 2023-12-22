//
//  DesignSystem.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/26.
//

import UIKit
// MARK: - 컬러

enum DesignSystemColor {
    case lightGreen
    case green
    case mint
    case brightmint
    case signature
    case red
    case ruby
    case gray
    case icongray
    case white
    case yellow
    case orange
    case pink
    case lavender
    case gray3
    case black
}

extension DesignSystemColor {
    var value: UIColor {
        switch self {
        case .lightGreen:
            return UIColor(hex: "11D796")
        case .green:
            return UIColor(hex: "009967")
        case .brightmint:
            return UIColor(hex: "E7F9F3")
        case .mint:
            return UIColor(hex: "02BE81")
        case .signature:
            return UIColor(hex: "475FFD")
        case .red:
            return UIColor(hex: "FF2323")
        case .ruby:
            return UIColor(hex: "FF2F2F")
        case .gray:
            return UIColor(hex: "D9D9D9")
        case .icongray:
            return UIColor(hex: "6E707B")
        case .white:
            return UIColor(hex: "FFFFFF")
        case .yellow:
            return UIColor(hex: "FFF5D3")
        case.orange:
            return UIColor(hex: "F98A08")
        case .pink:
            return UIColor(hex: "FFE8E8")
        case .lavender:
            return UIColor(hex: "E8EBFE")
        case .gray3:
            return UIColor(hex: "BFC3D4")
        case .black:
            return UIColor(hex: "000000")
        }
    }
}
// MARK: - 폰트
enum DesignSystemFont {
    case bold22L100
    case semibold20L140
    case semibold18L100
    case medium16L100
    case medium16L150
    case semibold14L150
    case regular14L150
    case medium12L150
    
}

extension DesignSystemFont {
    var value: UIFont {
        switch self {
        case .bold22L100:
            return UIFont.pretendard(.bold, size: 22)
        case .semibold20L140:
            return UIFont.pretendard(.semiBold, size: 22)
        case .semibold18L100:
            return UIFont.pretendard(.semiBold, size: 18)
        case .medium16L100:
            return UIFont.pretendard(.medium, size: 16)
        case .medium16L150:
            return UIFont.pretendard(.medium, size: 16)
        case .semibold14L150:
            return UIFont.pretendard(.semiBold, size: 14)
        case .regular14L150:
            return UIFont.pretendard(.regular, size: 14)
        case .medium12L150:
            return UIFont.pretendard(.regular, size: 14)
        }
    }
    
    var lineHeightMultiple: CGFloat {
        switch self {
        case .bold22L100:
            return 0.84
        case .semibold20L140:
            return 1.17
        case .semibold18L100:
            return 0.84
        case .medium16L100:
            return 0.84
        case .medium16L150:
            return 1.26
        case .semibold14L150:
            return 1.26
        case .regular14L150:
            return 1.26
        case .medium12L150:
            return 1.26
        }
    }
    
}

// MARK: - 아이콘
enum DesignSystemIcon {
    case setting
    case emptyAlarm
    case alarm
    case filter
    case verticalEllipsis
    case emptyCircleCheckmark
    case circleCheckmark
    case emptySquareCheckmark
    case squareCheckmark
    
}

extension DesignSystemIcon {
    var imageName: String {
        switch self {
        case .setting:
            return "setting"
        case .emptyAlarm:
            return "emptyAlarm"
        case .alarm:
            return "alarm"
        case .filter:
            return "filter"
        case .verticalEllipsis:
            return "verticalEllipsis"
        case .emptyCircleCheckmark:
            return "emptyCircleCheckmark"
        case .circleCheckmark:
            return "circleCheckmark"
        case .emptySquareCheckmark:
            return "emptySquareCheckmark"
        case .squareCheckmark:
            return "squareCheckmark"
        }
    }
}
