import SnapKit
import Then
import UIKit

final class MG2SettingsRowControl: UIControl {
    private let titleLabel = UILabel().then {
        $0.apply(.settingRow)
        // 큰 글자에서는 자르지 않고 줄을 바꿔 행이 커진다.
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private let detailLabel = UILabel().then {
        $0.apply(.settingRow, color: DS.Color.sub)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let chevronImageView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = DS.Color.ghost
    }

    /// 탈퇴처럼 되돌릴 수 없는 행만 `danger`.
    init(title: String, detail: String? = nil, isDestructive: Bool = false) {
        super.init(frame: .zero)
        titleLabel.text = title
        if isDestructive { titleLabel.textColor = DS.Color.danger }
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

        let trailingView: UIView = detailLabel.isHidden ? chevronImageView : detailLabel
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().inset(12)
            $0.trailing.lessThanOrEqualTo(trailingView.snp.leading).offset(-12)
        }
        detailLabel.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
        chevronImageView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }
        // 행 높이 56 (`size-row`), 글자가 커지면 그만큼 늘어난다.
        snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(DS.Size.row)
            $0.height.equalTo(DS.Size.row).priority(.low)
        }
    }
}
