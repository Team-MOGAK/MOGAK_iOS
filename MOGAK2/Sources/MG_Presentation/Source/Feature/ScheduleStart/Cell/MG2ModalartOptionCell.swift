import UIKit
import SnapKit

final class MG2ModalartOptionCell: UITableViewCell {
    static let reuseIdentifier = "MG2ModalartOptionCell"

    private let modalartLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 12, bottom: 12, left: 20, right: 20)
        label.font = DesignSystemFont.medium16L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(modalartLabel)
        modalartLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with modalart: MG2ModalartOption) {
        modalartLabel.text = modalart.title
        let color = modalart.color.isEmpty
            ? DesignSystemColor.signature.value
            : UIColor(hex: modalart.color)
        modalartLabel.textColor = color
        modalartLabel.backgroundColor = color.withAlphaComponent(0.1)
    }
}
