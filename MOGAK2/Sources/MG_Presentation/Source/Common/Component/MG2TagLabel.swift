import UIKit

/// 모각 태그. 언제나 `-fg` 글자 on `-bg` 바탕. 판 칸이 62% 이상 차면 흰 바탕(onFill).
final class MG2TagLabel: UILabel {
    private let insets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)

    override init(frame: CGRect) {
        super.init(frame: frame)
        apply(.caption1)
        roundCorners(DS.Radius.tag)
        clipsToBounds = true
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, moak: DS.Moak, onFill: Bool = false) {
        self.text = text
        textColor = moak.fg
        backgroundColor = onFill ? DS.Color.surface : moak.bg
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}
