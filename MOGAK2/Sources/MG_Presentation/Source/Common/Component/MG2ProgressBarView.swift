import SnapKit
import UIKit

/// 진척 막대. 장식이라 숫자(%)와 함께 쓴다.
final class MG2ProgressBarView: UIView {
    private let fillView = UIView()
    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DS.Color.track
        isAccessibilityElement = false
        addSubview(fillView)
        snp.makeConstraints { $0.height.equalTo(8) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        fillView.layer.cornerRadius = bounds.height / 2
        fillView.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }

    func setProgress(_ value: Double, color: UIColor, animated: Bool) {
        progress = CGFloat(min(max(value, 0), 1))
        fillView.backgroundColor = color
        guard animated, !UIAccessibility.isReduceMotionEnabled else { return setNeedsLayout() }
        // `.md-bar` 0.5초 cubic-bezier(.2,.8,.2,1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) { self.layoutSubviews() }
    }
}
