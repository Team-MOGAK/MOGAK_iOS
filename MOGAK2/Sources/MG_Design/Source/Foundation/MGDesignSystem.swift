import UIKit

enum MGSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24
}

enum MGCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
}

enum MGShadow {
    static let color = UIColor.black.withAlphaComponent(0.08)
    static let opacity: Float = 1
    static let radius: CGFloat = 8
    static let offset = CGSize(width: 0, height: 3)
}

enum MGColor {
    static let background = UIColor.systemBackground
    static let surface = UIColor.secondarySystemBackground
    static let primary = UIColor(red: 0.16, green: 0.45, blue: 0.27, alpha: 1)
    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
}

enum MGFont {
    static func title() -> UIFont { UIFont.systemFont(ofSize: 20, weight: .bold) }
    static func body() -> UIFont { UIFont.systemFont(ofSize: 16, weight: .regular) }
    static func caption() -> UIFont { UIFont.systemFont(ofSize: 13, weight: .regular) }
    static func button() -> UIFont { UIFont.systemFont(ofSize: 16, weight: .semibold) }
}
