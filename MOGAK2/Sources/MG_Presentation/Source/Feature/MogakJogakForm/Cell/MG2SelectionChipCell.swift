import SnapKit
import UIKit

/// 칩 (`.md-chip`): 36pt 캡슐 · 13/700. 꺼짐 `fill` · `ink-2`, 켜짐 `accent`(모각 폼에서는 고른 모각 색 deep) · 흰 글자.
final class MG2SelectionChipCell: UICollectionViewCell {
    static let identifier = String(describing: MG2SelectionChipCell.self)
    static let height = DS.Size.chip
    static let font = T.footnoteBold.font

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
        titleLabel.font = Self.font
        titleLabel.snp.makeConstraints { $0.center.equalToSuperview() }
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
