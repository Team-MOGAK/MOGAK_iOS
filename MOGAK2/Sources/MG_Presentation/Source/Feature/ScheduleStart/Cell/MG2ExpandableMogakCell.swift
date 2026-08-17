import UIKit
import SnapKit

final class MG2ExpandableMogakCell: UITableViewCell {
    static let reuseIdentifier = "MG2ExpandableMogakCell"

    private let titleLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 12, bottom: 12, left: 20, right: 20)
        label.font = DesignSystemFont.medium16L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        imageView.tintColor = DesignSystemColor.icongray.value
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubviews(titleLabel, chevronImageView)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-12)
        }
        chevronImageView.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setExpanded(_ isExpanded: Bool) {
        chevronImageView.image = UIImage(
            systemName: isExpanded ? "chevron.up" : "chevron.down"
        )
    }

    func configure(with section: MG2MogakJogakSection) {
        titleLabel.text = section.title
        let color = section.color.isEmpty
            ? DesignSystemColor.signature.value
            : UIColor(hex: section.color)
        titleLabel.textColor = color
        titleLabel.backgroundColor = color.withAlphaComponent(0.1)
    }
}
