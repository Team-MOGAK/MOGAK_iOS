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

// 기존 화면은 그대로 두고 값만 모다라트 토큰(DS.Color)으로 연결.
extension DesignSystemColor {
    var value: UIColor {
        switch self {
        case .lightGreen: return DS.Color.success
        case .signature: return DS.Color.accent
        case .signatureBag: return DS.Color.canvas
        case .red: return DS.Color.danger
        case .gray2: return DS.Color.segment
        case .gray3: return DS.Color.disabled
        case .gray4: return DS.Color.muted
        case .gray5: return DS.Color.sub
        case .gray6: return DS.Color.ink
        case .black: return DS.Color.ink
        case .white: return DS.Color.surface
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
