import SnapKit
import UIKit

/// 입력 필드 (`.md-field`): 52pt · `fill` 바탕 · 모서리 14 · 글자 17/600.
/// 포커스 테두리 `accent` 2px, 잘못된 값 `danger` 2px, 글자가 있으면 오른쪽 44pt 지우기 버튼(안쪽 0 4 0 16).
final class MG2TextField: UITextField {
    var isInvalid = false {
        didSet { updateBorder() }
    }

    override var text: String? {
        didSet { updateClearButton() }
    }

    private let clearButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        borderStyle = .none
        backgroundColor = DS.Color.fill
        roundCorners(DS.Radius.field)
        font = T.body.font
        adjustsFontForContentSizeCategory = true
        textColor = DS.Color.ink
        tintColor = DS.Color.accent
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        leftViewMode = .always

        // 20pt 원 (`.md-field-clear span`).
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17)), for: .normal)
        clearButton.tintColor = DS.Color.disabled
        clearButton.frame = CGRect(x: 0, y: 0, width: DS.Size.touch, height: DS.Size.touch)
        clearButton.accessibilityLabel = "지우기"
        clearButton.addAction(UIAction { [weak self] _ in self?.clear() }, for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .always
        addAction(UIAction { [weak self] _ in self?.updateClearButton() }, for: .editingChanged)
        snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.button) }
        updateBorder()
        updateClearButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var placeholder: String? {
        didSet {
            // 글꼴은 필드 글꼴을 따라 글자 크기 설정에 맞춰 바뀐다.
            attributedPlaceholder = placeholder.map { NSAttributedString(string: $0, attributes: [.foregroundColor: DS.Color.placeholder]) }
        }
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: bounds.maxX - DS.Size.touch - 4, y: bounds.midY - DS.Size.touch / 2, width: DS.Size.touch, height: DS.Size.touch)
    }

    override func becomeFirstResponder() -> Bool {
        defer { updateBorder() }
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        defer { updateBorder() }
        return super.resignFirstResponder()
    }

    private func clear() {
        guard delegate?.textFieldShouldClear?(self) ?? true else { return }
        text = ""
        sendActions(for: .editingChanged)
    }

    private func updateClearButton() {
        clearButton.isHidden = text?.isEmpty ?? true
    }

    private func updateBorder() {
        layer.borderWidth = isInvalid || isFirstResponder ? 2 : 0
        layer.borderColor = (isInvalid ? DS.Color.danger : DS.Color.accent).cgColor
    }
}

/// 필드 라벨 (13/700 `ink-3`).
final class MG2FieldLabel: UILabel {
    init(_ text: String) {
        super.init(frame: .zero)
        apply(.footnoteBold, color: DS.Color.ink3)
        numberOfLines = 0
        self.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 검증 문구 (12/600): 회색 안내 → 빨강(잘못) → 초록 `success-deep`(통과).
final class MG2HintLabel: UILabel {
    enum State {
        case info, bad, ok
    }

    init() {
        super.init(frame: .zero)
        apply(.caption1Semi, color: DS.Color.muted)
        numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ text: String?, state: State = .info) {
        self.text = text
        switch state {
        case .info: textColor = DS.Color.muted
        case .bad: textColor = DS.Color.danger
        case .ok: textColor = DS.Color.successDeep
        }
        if state == .bad, let text { UIAccessibility.post(notification: .announcement, argument: text) }
    }
}

/// 온보딩 단계 · 화면 제목 + 설명 한 줄.
final class MG2ScreenHeaderView: UIStackView {
    init(title: String, subtitle: String? = nil, style: T = .onboardingTitle) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 8
        // 줄 높이까지 T 스타일대로 (설명은 15/22).
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: title, attributes: style.attributes())
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits = .header
        addArrangedSubview(titleLabel)
        if let subtitle {
            let subLabel = UILabel()
            subLabel.attributedText = NSAttributedString(string: subtitle, attributes: T.paragraph.attributes(color: DS.Color.sub))
            subLabel.numberOfLines = 0
            subLabel.adjustsFontForContentSizeCategory = true
            addArrangedSubview(subLabel)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    /// 하위 화면 공통 내비게이션 바: 제목 없음, 뒤로 버튼 `ink`, 그림자 없음.
    func applyStepNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.isHidden = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = view.backgroundColor
        appearance.titleTextAttributes = [.font: T.headline.font, .foregroundColor: DS.Color.ink]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = DS.Color.ink
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
