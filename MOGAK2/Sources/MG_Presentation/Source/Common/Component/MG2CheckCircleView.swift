import SnapKit
import UIKit

/// 조각 체크 원 28pt. 완료하면 모각 색(deep)으로 스프링 0.3초 채워진다. 터치는 행 전체가 받는다.
final class MG2CheckCircleView: UIView {
    private let fillView = UIView()
    private let checkView = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .heavy)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.borderWidth = 2
        layer.borderColor = DS.Color.border.cgColor
        checkView.tintColor = DS.Color.surface
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

    func setDone(_ isDone: Bool, color: UIColor, animated: Bool) {
        fillView.backgroundColor = color
        let apply = {
            self.fillView.alpha = isDone ? 1 : 0
            self.fillView.transform = isDone ? .identity : CGAffineTransform(scaleX: 0.4, y: 0.4)
        }
        guard animated, !UIAccessibility.isReduceMotionEnabled else { return apply() }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, animations: apply)
    }
}
