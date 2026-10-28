import UIKit

/// 모각 태그 (`.md-tag` 12/16 700 · 안쪽 3 8 · 모서리 8, 한 줄). 언제나 `-fg` 글자 on `-bg` 바탕. 판 칸이 62% 이상 차면 흰 바탕(onFill).
/// 좁은 판 칸에서는 0.8배까지 줄이고, 그래도 넘치면 끝을 줄인다(…).
final class MG2TagLabel: MG2PaddingLabel {
    init() {
        super.init(top: 3, bottom: 3, left: 8, right: 8)
        apply(.caption1)
        lineBreakMode = .byTruncatingTail
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.8
        roundCorners(DS.Radius.tag)
        clipsToBounds = true
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String, moak: DS.Moak, onFill: Bool = false) {
        self.text = text
        textColor = moak.fg
        backgroundColor = onFill ? DS.Color.surface : moak.bg
    }
}
