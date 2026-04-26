import UIKit

enum MGColor {
    static let primary = DesignSystemColor.signature.value
    static let background = DesignSystemColor.signatureBag.value
    static let surface = DesignSystemColor.white.value
    static let textPrimary = DesignSystemColor.black.value
    static let textSecondary = DesignSystemColor.gray4.value
    static let disabled = DesignSystemColor.gray3.value
    static let border = DesignSystemColor.gray2.value
}

enum MGFont {
    static let titleLarge = UIFont.pretendard(.bold, size: 24)
    static let title = UIFont.pretendard(.bold, size: 22)
    static let subtitle = UIFont.pretendard(.medium, size: 16)
    static let body = UIFont.pretendard(.regular, size: 16)
    static let caption = UIFont.pretendard(.medium, size: 14)
    static let button = UIFont.pretendard(.medium, size: 18)
}

enum MGSpacing {
    static let screenInset: CGFloat = 20
    static let section: CGFloat = 24
    static let item: CGFloat = 12
}
