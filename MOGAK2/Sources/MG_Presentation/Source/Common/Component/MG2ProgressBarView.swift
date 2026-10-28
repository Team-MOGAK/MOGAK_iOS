import SnapKit
import UIKit

/// 진척 막대 (`.md-bar` 8pt 캡슐). 장식이라 숫자(%)와 함께 쓴다.
final class MG2ProgressBarView: UIView {
    private let fillView = UIView()
    private var progress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DS.Color.track
        clipsToBounds = true
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
        layoutFill()
    }

    func setProgress(_ value: Double, color: UIColor, animated: Bool) {
        progress = CGFloat(min(max(value, 0), 1))
        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            fillView.backgroundColor = color
            return layoutFill()
        }
        // `.md-bar` 0.5초 ease-out. 막대만 움직이고 주변 레이아웃은 건드리지 않는다.
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]) {
            self.fillView.backgroundColor = color
            self.layoutFill()
        }
    }

    private func layoutFill() {
        fillView.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
    }
}
