import UIKit

extension UIView {
    func applyMGCardStyle() {
        backgroundColor = MGColor.surface
        layer.cornerRadius = MGCornerRadius.medium
        layer.shadowColor = MGShadow.color.cgColor
        layer.shadowOpacity = MGShadow.opacity
        layer.shadowRadius = MGShadow.radius
        layer.shadowOffset = MGShadow.offset
        layer.masksToBounds = false
    }
}
