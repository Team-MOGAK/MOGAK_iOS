import UIKit
import SnapKit

final class MG2AgreementRowView: UIView {
    var onToggle: (() -> Void)?

    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkOff"), for: .normal)
        button.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 16)
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChecked(_ isChecked: Bool) {
        checkButton.setImage(UIImage(named: isChecked ? "checkOn" : "checkOff"), for: .normal)
    }

    private func configureLayout() {
        addSubviews(checkButton, titleLabel)

        checkButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        snp.makeConstraints {
            $0.height.equalTo(24)
        }
    }

    @objc private func checkButtonTapped() {
        onToggle?()
    }
}
