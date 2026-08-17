import UIKit
import SnapKit

final class MG2SelectableJogakCell: UITableViewCell {
    static let reuseIdentifier = "MG2SelectableJogakCell"

    var onSelection: ((Int) -> Void)?

    private var jogakID = 0
    private var isLocked = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFont.medium16L150.value
        return label
    }()

    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(hex: DesignSystemPalette.neutralGrayHex)
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubviews(checkImageView, titleLabel)

        checkImageView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.leading.equalToSuperview().inset(40)
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkImageView.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }

        contentView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap))
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSelection = nil
        jogakID = 0
        isLocked = false
    }

    func configure(with item: MG2JogakSelectionItem, isSelected: Bool) {
        titleLabel.text = item.title
        jogakID = item.id
        isLocked = !item.isSelectable
        setSelectedAppearance(isLocked || isSelected)
        contentView.alpha = isLocked ? 0.6 : 1
    }

    func setSelectedAppearance(_ isSelected: Bool) {
        checkImageView.image = UIImage(systemName: isSelected ? "checkmark.square.fill" : "square")
        checkImageView.tintColor = isSelected
            ? DesignSystemColor.lightGreen.value
            : UIColor(hex: DesignSystemPalette.neutralGrayHex)
    }

    @objc private func didTap() {
        guard !isLocked else { return }
        onSelection?(jogakID)
    }
}
