import UIKit

extension UIControl {
    /// 누르면 0.96배(스프링 0.15초), 떼면 살짝 튕기며 돌아온다. 동작 줄이기를 켜면 크기는 그대로 둔다.
    func enablePressFeedback() {
        addTarget(self, action: #selector(mg2PressDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(mg2PressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    @objc private func mg2PressDown() {
        animatePress(to: CGAffineTransform(scaleX: 0.96, y: 0.96), duration: 0.15, bounce: 0)
    }

    @objc private func mg2PressUp() {
        animatePress(to: .identity, duration: 0.3, bounce: 0.3)
    }

    private func animatePress(to target: CGAffineTransform, duration: TimeInterval, bounce: CGFloat) {
        guard !UIAccessibility.isReduceMotionEnabled else { return transform = .identity }
        UIView.animate(springDuration: duration, bounce: bounce, initialSpringVelocity: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) { self.transform = target }
    }
}

extension UIView {
    /// 모서리를 iOS 연속 곡률로.
    func roundCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
    }
}
