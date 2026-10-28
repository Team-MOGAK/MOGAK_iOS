import UIKit

/// 광고 표시 (`.md-adbadge` 11/16 800 · 안쪽 1 6 · 모서리 4 · 높이 18). 모든 광고에 붙인다 (AdMob 정책: 앱 버튼과 다르게).
final class MG2AdBadgeLabel: MG2PaddingLabel {
    init() {
        super.init(top: 1, bottom: 1, left: 6, right: 6)
        text = "광고"
        font = .scaledCapped(.pretendard(.extraBold, size: 11), relativeTo: .caption2)
        adjustsFontForContentSizeCategory = true
        textColor = DS.Color.sub
        backgroundColor = DS.Color.segment
        layer.cornerRadius = 4
        clipsToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: max(size.height, 18))
    }
}
