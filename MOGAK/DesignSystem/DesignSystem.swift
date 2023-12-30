//
//  DesignSystem.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/26.
//

import UIKit

// MARK: - 컬러
enum DesignSystemColor {
    case pink
    case yellow
    case orange
    case purple
    case skyblue
    case lightGreen
    case green //sub color
    case signature //main color
    case signatureBag //main background color
    case red
    case gray
    case white
    case gray2 //2
    case gray3 //3 -> disable
    case gray4 //4
    case gray5 //5
    case gray6 //6 Text
    case black //7
}

extension DesignSystemColor {
    var value: UIColor {
        switch self {
        case .pink:
            return UIColor(hex: "FF4C77")
        case .lightGreen:
            return UIColor(hex: "11D796")
        case .green:
            return UIColor(hex: "009967")
        case .signature:
            return UIColor(hex: "475FFD")
        case .signatureBag:
            return UIColor(hex: "F1F3FA")
        case .red:
            return UIColor(hex: "FF2323")
        case .gray:
            return UIColor(hex: "D9D9D9")
        case .white:
            return UIColor(hex: "FFFFFF")
        case .yellow:
            return UIColor(hex: "F98A08")
        case .orange:
            return UIColor(hex: "FF6827")
        case .purple:
            return UIColor(hex: "9C31FF")
        case .skyblue:
            return UIColor(hex: "21CAFF")
        case .gray2:
            return UIColor(hex: "EEF0F8")
        case .gray3:
            return UIColor(hex: "BFC3D4")
        case .gray4:
            return UIColor(hex: "808497")
        case .gray5:
            return UIColor(hex: "6E707B")
        case .gray6:
            return UIColor(hex: "24252E")
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
    case medium18140
    case semibold14L150
    case regular14L150
    case regular16L150
    case medium12L150
    
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
        case .medium18140:
            return UIFont.pretendard(.medium, size: 18)
        case .semibold14L150:
            return UIFont.pretendard(.semiBold, size: 14)
        case .regular14L150:
            return UIFont.pretendard(.regular, size: 14)
        case .regular16L150:
            return UIFont.pretendard(.regular, size: 16)
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
        case .medium18140:
            return 1.26
        case .regular16L150:
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
