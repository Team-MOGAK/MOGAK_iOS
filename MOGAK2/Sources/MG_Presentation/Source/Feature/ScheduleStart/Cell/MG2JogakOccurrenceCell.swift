import UIKit
import SnapKit

final class MG2JogakOccurrenceCell: UITableViewCell {
    static let reuseIdentifier = "MG2JogakOccurrenceCell"

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

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(
            by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onMoreTapped = nil
    }

    func configure(
        title: String,
        status: MG2JogakOccurrenceStatus,
        onMoreTapped: @escaping () -> Void
    ) {
        titleLabel.text = title
        setStatus(status)
        self.onMoreTapped = onMoreTapped
    }

    func setStatus(_ status: MG2JogakOccurrenceStatus) {
        completionImageView.image = UIImage(
            named: status == .success ? "squareCheckmark" : "emptySquareCheckmark"
        )
        completionImageView.tintColor = nil
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
