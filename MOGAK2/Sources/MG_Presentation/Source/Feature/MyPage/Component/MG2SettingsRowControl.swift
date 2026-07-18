import SnapKit
import Then
import UIKit

final class MG2SettingsRowControl: UIControl {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "24252E")
    }

    private let detailLabel = UILabel().then {
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.textColor = UIColor(hex: "BFC3D4")
    }

    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = UIColor(hex: "24252E")
    }

    init(title: String, detail: String? = nil) {
        super.init(frame: .zero)
        titleLabel.text = title
        detailLabel.text = detail
        detailLabel.isHidden = detail == nil
        chevronImageView.isHidden = detail != nil
        accessibilityLabel = title
        accessibilityValue = detail
        accessibilityTraits = detail == nil ? .button : .staticText
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }

    private func configureLayout() {
        addSubviews(titleLabel, detailLabel, chevronImageView)

        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        detailLabel.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
        chevronImageView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }
        snp.makeConstraints {
            $0.height.equalTo(22)
        }
    }
}
