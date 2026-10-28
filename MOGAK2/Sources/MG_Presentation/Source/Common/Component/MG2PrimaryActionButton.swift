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

    /// 좌우 여백 (soft 12 · 나머지 20).
    private var horizontalPadding: CGFloat { style == .soft ? 12 : 20 }

    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width + horizontalPadding * 2, height: style.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 글자는 좌우 여백 안에서 한 줄. 넘치면 0.8배까지 줄이고 그다음 끝을 줄인다.
        titleLabel?.frame = bounds.insetBy(dx: horizontalPadding, dy: 0)
        dashLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.75, dy: 0.75), cornerRadius: DS.Radius.button).cgPath
    }

    /// soft(36)도 누르는 영역은 최소 44 × 44.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let dx = min((bounds.width - DS.Size.touch) / 2, 0)
        let dy = min((bounds.height - DS.Size.touch) / 2, 0)
        return bounds.insetBy(dx: dx, dy: dy).contains(point)
    }

    private func configureLayout() {
        roundCorners(style == .soft ? 10 : DS.Radius.button)
        // T 글자는 이미 크기 조절된 폰트라 다시 조절하지 않는다 (두 번 조절하면 크래시).
        // primary 17/700 · dashed · danger 15/700 · soft 13/700 · ghost 15/600.
        titleLabel?.font = {
            switch style {
            case .primary: return T.button.font
            case .dashed, .danger: return T.subhead.font
            case .soft: return T.footnoteBold.font
            case .ghost: return .scaledCapped(.pretendard(.semiBold, size: 15), relativeTo: .subheadline)
            }
        }()
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.8
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
