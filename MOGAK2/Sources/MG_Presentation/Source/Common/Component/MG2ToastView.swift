import SnapKit
import UIKit

/// 아래쪽 토스트 (`.md-toast`). 버튼 없으면 2.4초, 버튼이 있으면 4초. 버튼은 하나만.
final class MG2ToastView: UIView {
    private var action: (() -> Void)?

    private init(title: String, subtitle: String?, actionTitle: String?, action: (() -> Void)?) {
        self.action = action
        super.init(frame: .zero)
        backgroundColor = DS.Color.toast
        roundCorners(18)
        layer.apply(.toast)

        let okView = UIView()
        okView.backgroundColor = DS.Color.success
        okView.layer.cornerRadius = 15
        let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .black)))
        check.tintColor = DS.Color.surface
        okView.addSubview(check)

        let titleLabel = UILabel()
        titleLabel.apply(.callout, color: DS.Color.surface)
        titleLabel.font = .pretendard(.bold, size: 15)
        titleLabel.text = title
        let subLabel = UILabel()
        subLabel.apply(.footnote, color: DS.Color.toastSub)
        subLabel.text = subtitle
        subLabel.isHidden = subtitle == nil
        let texts = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        texts.axis = .vertical
        texts.spacing = 1

        let row = UIStackView(arrangedSubviews: [okView, texts])
        row.spacing = 12
        row.alignment = .center
        if let actionTitle {
            let button = UIButton(type: .system)
            button.setTitle(actionTitle, for: .normal)
            button.setTitleColor(DS.Color.surface, for: .normal)
            button.titleLabel?.font = T.footnoteBold.font
            button.backgroundColor = UIColor.white.withAlphaComponent(0.14)
            button.roundCorners(10)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            button.addAction(UIAction { [weak self] _ in self?.action?(); self?.removeFromSuperview() }, for: .touchUpInside)
            button.snp.makeConstraints { $0.height.equalTo(DS.Size.chip); $0.width.greaterThanOrEqualTo(DS.Size.touch) }
            button.setContentHuggingPriority(.required, for: .horizontal)
            row.addArrangedSubview(button)
        }
        addSubview(row)
        okView.snp.makeConstraints { $0.size.equalTo(30) }
        check.snp.makeConstraints { $0.center.equalToSuperview() }
        row.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)) }
        isAccessibilityElement = actionTitle == nil
        accessibilityLabel = [title, subtitle].compactMap { $0 }.joined(separator: ", ")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func show(in view: UIView, title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        view.subviews.filter { $0 is MG2ToastView }.forEach { $0.removeFromSuperview() }
        let toast = MG2ToastView(title: title, subtitle: subtitle, actionTitle: actionTitle, action: action)
        view.addSubview(toast)
        toast.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(view.safeAreaLayoutGuide).offset(-DS.Space.gutter * 2).priority(.high)
            $0.width.lessThanOrEqualTo(380)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(DS.Space.gutter)
        }
        toast.alpha = 0
        UIView.animate(withDuration: 0.2) { toast.alpha = 1 }
        UIAccessibility.post(notification: .announcement, argument: toast.accessibilityLabel)
        let duration: TimeInterval = actionTitle == nil ? 2.4 : 4
        UIView.animate(withDuration: 0.3, delay: duration, options: [.curveEaseIn, .allowUserInteraction]) { toast.alpha = 0 } completion: { _ in toast.removeFromSuperview() }
    }
}
