import UIKit
import SnapKit

final class MG2AgreementRowView: UIView {
    var onToggle: (() -> Void)?
    var onDetail: (() -> Void)?

    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkOff"), for: .normal)
        button.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 16)
        return label
    }()

    private lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = DesignSystemColor.gray4.value
        button.addTarget(self, action: #selector(detailTapped), for: .touchUpInside)
        return button
    }()

    init(title: String, showsDetail: Bool) {
        super.init(frame: .zero)
        titleLabel.text = title
        detailButton.isHidden = !showsDetail
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChecked(_ isChecked: Bool) {
        checkButton.setImage(
            UIImage(named: isChecked ? "checkOn" : "checkOff"),
            for: .normal
        )
    }

    private func configureLayout() {
        addSubviews(checkButton, titleLabel, detailButton)

        checkButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(detailButton.snp.leading).offset(-8)
        }
        detailButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        snp.makeConstraints {
            $0.height.equalTo(24)
        }
    }

    @objc private func toggleTapped() {
        onToggle?()
    }

    @objc private func detailTapped() {
        onDetail?()
    }
}
