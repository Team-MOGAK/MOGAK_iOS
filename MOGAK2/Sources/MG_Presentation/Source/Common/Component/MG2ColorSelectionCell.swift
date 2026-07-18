import UIKit
import SnapKit

final class MG2ColorSelectionCell: UICollectionViewCell {
    static let identifier = String(describing: MG2ColorSelectionCell.self)

    private let colorView = UIView()
    private let innerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            innerView.backgroundColor = isSelected ? DesignSystemColor.white.value : .clear
        }
    }

    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }

    private func configureLayout() {
        colorView.layer.cornerRadius = 20
        colorView.clipsToBounds = true
        innerView.layer.cornerRadius = 12
        innerView.clipsToBounds = true

        contentView.addSubview(colorView)
        colorView.addSubview(innerView)

        colorView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }

        innerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}
