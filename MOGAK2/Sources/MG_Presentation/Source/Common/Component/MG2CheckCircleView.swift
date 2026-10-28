import SnapKit
import UIKit

/// 조각 체크 원 28pt (`.md-check`). 꺼짐은 모각 `base` 테두리 2, 완료하면 `deep`으로 스프링 0.3초 채워진다. 터치는 행 전체가 받는다.
final class MG2CheckCircleView: UIView {
    private let fillView = UIView()
    private let checkView = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .heavy)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.borderWidth = 2
        layer.borderColor = DS.Color.border.cgColor
        checkView.tintColor = DS.Color.surface
        fillView.alpha = 0
        addSubview(fillView)
        fillView.addSubview(checkView)
        snp.makeConstraints { $0.size.equalTo(DS.Size.check) }
        fillView.snp.makeConstraints { $0.edges.equalToSuperview() }
        checkView.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        fillView.layer.cornerRadius = bounds.height / 2
    }

    /// `color`는 채움(deep). 꺼짐 테두리는 같은 모각의 `base`, 모각 색이 아니면 `color` 그대로.
    /// 테두리는 채움 위에 그려지므로 완료 때는 채움과 같은 색으로 둔다.
    func setDone(_ isDone: Bool, color: UIColor, animated: Bool) {
        fillView.backgroundColor = color
        let ring = DS.Moak.allCases.first { $0.deep == color }?.base ?? color
        layer.borderColor = (isDone ? color : ring).cgColor
        let apply = {
            self.fillView.alpha = isDone ? 1 : 0
            self.fillView.transform = isDone ? .identity : CGAffineTransform(scaleX: 0.4, y: 0.4)
        }
        guard animated, !UIAccessibility.isReduceMotionEnabled else { return apply() }
        UIView.animate(springDuration: 0.3, bounce: isDone ? 0.35 : 0, initialSpringVelocity: 0, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: apply)
    }
}
