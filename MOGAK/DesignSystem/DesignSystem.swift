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
    case signature
    case red
    case gray
    case white
}

extension DesignSystemColor {
    var value: UIColor {
        switch self {
        case .lightGreen:
            return UIColor(hex: "11D796")
        case .green:
            return UIColor(hex: "009967")
        case .signature:
            return UIColor(hex: "475FFD")
        case .red:
            return UIColor(hex: "FF2323")
        case .gray:
            return UIColor(hex: "D9D9D9")
        case .white:
            return UIColor(hex: "FFFFFF")
        }
    }
}
// MARK: - 폰트
enum DesignSystemFont {
    case bold22L100(lineHeightMultiple: CGFloat = 0.84)
    case semibold20L140(lineHeightMultiple: CGFloat = 1.17)
    case semibold18L100(lineHeightMultiple: CGFloat = 0.84)
    case medium16L100(lineHeightMultiple: CGFloat = 0.84)
    case medium16L150(lineHeightMultiple: CGFloat = 1.26)
    case semibold14L150(lineHeightMultiple: CGFloat = 1.26)
    case regular14L150(lineHeightMultiple: CGFloat = 1.26)
    case medium12L150(lineHeightMultiple: CGFloat = 0.84)
    
}

extension DesignSystemFont {
    var value: UIFont {
        switch self {
        case .bold22L100:
            return UIFont.pretendard(.bold, size: 22)
        case .semibold20L140:
            return UIFont.pretendard(.semiBold, size: 20)
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
        case .bold22L100(let multiple):
            return multiple
        case .semibold20L140(let multiple):
            return multiple
        case .semibold18L100(let multiple):
            return multiple
        case .medium16L100(let multiple):
            return multiple
        case .medium16L150(let multiple):
            return multiple
        case .semibold14L150(let multiple):
            return multiple
        case .regular14L150(let multiple):
            return multiple
        case .medium12L150(let multiple):
            return multiple
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
