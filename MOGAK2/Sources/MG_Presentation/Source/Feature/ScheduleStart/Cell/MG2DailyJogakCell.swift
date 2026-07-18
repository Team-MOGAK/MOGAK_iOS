import UIKit
import SnapKit

final class MG2DailyJogakCell: UITableViewCell {
    static let reuseIdentifier = "MG2DailyJogakCell"

    private let completionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 5
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(hex: "6E707B")
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return button
    }()

    private var onMoreTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onMoreTapped = nil
    }

    func configure(title: String, isCompleted: Bool, onMoreTapped: @escaping () -> Void) {
        titleLabel.text = title
        setCompleted(isCompleted)
        self.onMoreTapped = onMoreTapped
    }

    func setCompleted(_ isCompleted: Bool) {
        completionImageView.image = UIImage(
            named: isCompleted ? "squareCheckmark" : "emptySquareCheckmark"
        )
    }

    @objc private func moreButtonTapped() {
        onMoreTapped?()
    }

    private func configureLayout() {
        contentView.addSubviews(completionImageView, titleLabel, moreButton)

        completionImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(completionImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
        }
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }

        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 10
    }
}
