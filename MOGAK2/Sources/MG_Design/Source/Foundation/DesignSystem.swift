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
    case signature //main color
    case signatureBag //main background color
    case red
    case white
    case gray2 //2
    case gray3 //3 -> disable
    case gray4 //4
    case gray5 //5
    case gray6 //6 Text
    case black //7
}

enum DesignSystemPalette {
    static let signatureHex = "475FFD"
    static let neutralGrayHex = "BFC3D4"
    static let modalartColors = [
        "475FFD", "11D796", "009967", "FF2323",
        "F98A08", "FF6827", "9C31FF", "21CAFF"
    ]
    static let mogakColors = [
        "475FFD", "FF4C77", "F98A08", "11D796",
        "FF6827", "9C31FF", "21CAFF", "FF2F2F"
    ]
}

extension DesignSystemColor {
    var value: UIColor {
        switch self {
        case .lightGreen:
            return UIColor(hex: "11D796")
        case .signature:
            return UIColor(hex: "475FFD")
        case .signatureBag:
            return UIColor(hex: "F1F3FA")
        case .red:
            return UIColor(hex: "FF2323")
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
        case .white:
            return UIColor(hex: "FFFFFF")
        }
    }
}

// MARK: - 폰트
enum DesignSystemFont {
    case semibold20L140
    case semibold18L100
    case medium16L100
    case medium16L150
    case medium18L140
    case semibold14L150
    case regular14L150
    case regular16L150
    case medium12L150
}

extension DesignSystemFont {
    var value: UIFont {
        switch self {
        case .semibold20L140:
            return UIFont.pretendard(.semiBold, size: 20)
        case .semibold18L100:
            return UIFont.pretendard(.semiBold, size: 18)
        case .medium16L100:
            return UIFont.pretendard(.medium, size: 16)
        case .medium16L150:
            return UIFont.pretendard(.medium, size: 16)
        case .medium18L140:
            return UIFont.pretendard(.medium, size: 18)
        case .semibold14L150:
            return UIFont.pretendard(.semiBold, size: 14)
        case .regular14L150:
            return UIFont.pretendard(.regular, size: 14)
        case .regular16L150:
            return UIFont.pretendard(.regular, size: 16)
        case .medium12L150:
            return UIFont.pretendard(.medium, size: 12)
        }
    }
}
