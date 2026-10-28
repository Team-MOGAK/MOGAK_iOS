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

        // `.md-toast-t` 15/20 700 · `.md-toast-s` 13/18 500. 잘리지 않게 여러 줄.
        let titleLabel = UILabel()
        titleLabel.apply(.subhead, color: DS.Color.surface)
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        let subLabel = UILabel()
        subLabel.apply(.footnote, color: DS.Color.toastSub)
        subLabel.numberOfLines = 0
        subLabel.text = subtitle
        subLabel.isHidden = subtitle == nil
        let texts = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        texts.axis = .vertical
        texts.spacing = 1

        let row = UIStackView(arrangedSubviews: [okView, texts])
        row.spacing = 12
        row.alignment = .center
        if let actionTitle {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(actionTitle, attributes: AttributeContainer([.font: T.footnoteBold.font]))
            configuration.baseForegroundColor = DS.Color.surface
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            configuration.background.backgroundColor = UIColor.white.withAlphaComponent(0.14)
            configuration.background.cornerRadius = 10
            configuration.titleLineBreakMode = .byTruncatingTail
            let button = UIButton(configuration: configuration)
            button.addAction(UIAction { [weak self] _ in self?.action?(); self?.fadeOut() }, for: .touchUpInside)
            button.snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.chip); $0.width.greaterThanOrEqualTo(DS.Size.touch) }
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        // 아래에서 스프링으로 올라온다. 동작 줄이기면 페이드만.
        toast.alpha = 0
        if !UIAccessibility.isReduceMotionEnabled { toast.transform = CGAffineTransform(translationX: 0, y: 40) }
        UIView.animate(springDuration: 0.45, bounce: 0.2, initialSpringVelocity: 0, delay: 0, options: .allowUserInteraction) {
            toast.alpha = 1
            toast.transform = .identity
        }
        UIAccessibility.post(notification: .announcement, argument: toast.accessibilityLabel)
        // 지연 애니메이션은 alpha를 바로 0으로 바꿔 버튼 터치를 막으므로, 시간이 지난 뒤에 숨긴다.
        let duration: TimeInterval = actionTitle == nil ? 2.4 : 4
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak toast] in toast?.fadeOut() }
    }

    private func fadeOut() {
        guard superview != nil else { return }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) { self.alpha = 0 } completion: { _ in self.removeFromSuperview() }
    }
}
