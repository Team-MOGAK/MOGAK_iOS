import SnapKit
import UIKit

final class MG2SelectionChipCell: UICollectionViewCell {
    enum Style {
        case category
        case weekday

        var font: UIFont {
            switch self {
            case .category:
                return UIFont.pretendard(.medium, size: 14)
            case .weekday:
                return UIFont.pretendard(.medium, size: 16)
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .category:
                return 16
            case .weekday:
                return 24
            }
        }

        var normalBackgroundColor: UIColor {
            switch self {
            case .category:
                return UIColor(hex: "F1F3FA")
            case .weekday:
                return UIColor(hex: "EEF0F8")
            }
        }
    }

    private let titleLabel = UILabel()
    private var style = Style.category

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.layer.masksToBounds = true
        titleLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        style = .category
        updateAppearance()
    }

    func configure(title: String, style: Style) {
        self.style = style
        titleLabel.text = title
        titleLabel.font = style.font
        contentView.layer.cornerRadius = style.cornerRadius
        updateAppearance()
    }

    private func updateAppearance() {
        contentView.backgroundColor = isSelected
            ? UIColor(hex: "475FFD")
            : style.normalBackgroundColor
        titleLabel.textColor = isSelected
            ? .white
            : UIColor(hex: "24252E")
    }
}
