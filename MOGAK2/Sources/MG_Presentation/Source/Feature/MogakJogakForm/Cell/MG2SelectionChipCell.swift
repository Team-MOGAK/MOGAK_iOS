import SnapKit
import UIKit

/// 칩 (`.md-chip`): 36pt 캡슐 · 13/700. 꺼짐 `fill` · `ink-2`, 켜짐 `accent`(모각 폼에서는 고른 모각 색 deep) · 흰 글자.
final class MG2SelectionChipCell: UICollectionViewCell {
    static let identifier = String(describing: MG2SelectionChipCell.self)
    static let height = DS.Size.chip
    /// 글자 크기 설정이 바뀌어도 새 크기로 재도록 매번 만든다.
    static var font: UIFont { T.footnoteBold.font }

    enum Style {
        case category
        /// 루틴 요일: 같은 칩을 원형으로.
        case weekday
    }

    private let titleLabel = UILabel()
    private var selectedColor = DS.Color.accent

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.layer.masksToBounds = true
        titleLabel.apply(.footnoteBold, color: DS.Color.ink2)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        // 칸 크기가 고정이라 넘치면 한 줄 안에서 조금 줄인다.
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(4)
        }
        isAccessibilityElement = true
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        selectedColor = DS.Color.accent
        updateAppearance()
    }

    func configure(title: String, style: Style, selectedColor: UIColor = DS.Color.accent) {
        titleLabel.text = title
        self.selectedColor = selectedColor
        accessibilityLabel = title
        updateAppearance()
    }

    /// 칩 너비: 글자 + 좌우 14.
    static func size(for title: String) -> CGSize {
        CGSize(width: ceil((title as NSString).size(withAttributes: [.font: font]).width) + 28, height: height)
    }

    private func updateAppearance() {
        contentView.backgroundColor = isSelected ? selectedColor : DS.Color.fill
        titleLabel.textColor = isSelected ? DS.Color.surface : DS.Color.ink2
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }
}
