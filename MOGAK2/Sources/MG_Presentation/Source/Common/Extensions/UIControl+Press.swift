import UIKit

extension UIControl {
    /// 누르면 0.96배(0.15초). 동작 줄이기를 켜면 크기는 그대로 둔다.
    func enablePressFeedback() {
        addTarget(self, action: #selector(mg2PressDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(mg2PressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    @objc private func mg2PressDown() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        UIView.animate(withDuration: 0.15) { self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
    }

    @objc private func mg2PressUp() {
        UIView.animate(withDuration: 0.15) { self.transform = .identity }
    }
}

extension UIView {
    /// 모서리를 iOS 연속 곡률로.
    func roundCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
    }
}
