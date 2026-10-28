import UIKit

/// 디자인 시스템 버튼 (bundle.css `.md-btn`).
/// primary 52 · 확정, dashed 48 · 목록 끝 더 가져오기, soft 36 · 줄 안 보조, ghost 44 · 거절, danger 44 · 시트 안 삭제.
final class MG2PrimaryActionButton: UIButton {
    enum Style {
        case primary, dashed, soft, ghost, danger

        var height: CGFloat {
            switch self {
            case .primary: return DS.Size.button
            case .dashed: return 48
            case .soft: return DS.Size.chip
            case .ghost, .danger: return DS.Size.touch
            }
        }
    }

    let style: Style
    private let dashLayer = CAShapeLayer()

    override var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    init(style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        configureLayout()
    }

    override convenience init(frame: CGRect) {
        self.init(style: .primary)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: style.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.75, dy: 0.75), cornerRadius: DS.Radius.button).cgPath
    }

    private func configureLayout() {
        roundCorners(style == .soft ? 10 : DS.Radius.button)
        let font: UIFont = {
            switch style {
            case .primary: return T.button.font
            case .dashed, .danger: return .pretendard(.bold, size: 15)
            case .soft: return T.footnoteBold.font
            case .ghost: return .pretendard(.semiBold, size: 15)
            }
        }()
        titleLabel?.font = UIFontMetrics.default.scaledFont(for: font, maximumPointSize: font.pointSize * 1.4)
        titleLabel?.adjustsFontForContentSizeCategory = true
        contentEdgeInsets = UIEdgeInsets(top: 0, left: style == .soft ? 12 : 20, bottom: 0, right: style == .soft ? 12 : 20)
        if style == .dashed {
            dashLayer.fillColor = nil
            dashLayer.strokeColor = DS.Color.accentLine.cgColor
            dashLayer.lineWidth = 1.5
            dashLayer.lineDashPattern = [5, 4]
            layer.addSublayer(dashLayer)
        }
        enablePressFeedback()
        updateAppearance()
    }

    private func updateAppearance() {
        let (background, title): (UIColor, UIColor) = {
            switch style {
            case .primary: return (isEnabled ? DS.Color.accent : DS.Color.disabled, DS.Color.surface)
            case .dashed: return (.clear, DS.Color.accentDeep)
            case .soft: return (DS.Color.accentSoft, DS.Color.accentDeep)
            case .ghost: return (.clear, DS.Color.sub)
            case .danger: return (.clear, DS.Color.danger)
            }
        }()
        backgroundColor = background
        setTitleColor(title, for: .normal)
        setTitleColor(style == .primary ? DS.Color.surface : DS.Color.disabled, for: .disabled)
    }
}
