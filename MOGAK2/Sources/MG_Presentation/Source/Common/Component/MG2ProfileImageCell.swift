import UIKit
import SnapKit

final class MG2ProfileImageCell: UICollectionViewCell {
    static let identifier = String(describing: MG2ProfileImageCell.self)

    private let imageView = UIImageView()

    override var isSelected: Bool {
        didSet { updateBorder() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        updateBorder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.height / 2
    }

    func configure(imageName: String) {
        imageView.image = UIImage(named: imageName)
    }

    private func updateBorder() {
        imageView.layer.borderWidth = isSelected ? 3 : 1
        imageView.layer.borderColor = (isSelected ? DesignSystemColor.signature.value : DesignSystemColor.gray2.value).cgColor
    }
}
