import SnapKit
import UIKit

/// 광고 표시 (`.md-adbadge`). 모든 광고에 붙인다 (AdMob 정책: 앱 버튼과 다르게).
final class MG2AdBadgeLabel: UILabel {
    private let insets = UIEdgeInsets(top: 1, left: 6, bottom: 1, right: 6)

    override init(frame: CGRect) {
        super.init(frame: frame)
        text = "광고"
        font = .pretendard(.extraBold, size: 11)
        textColor = DS.Color.sub
        backgroundColor = DS.Color.segment
        layer.cornerRadius = 4
        clipsToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: 18)
    }
}
