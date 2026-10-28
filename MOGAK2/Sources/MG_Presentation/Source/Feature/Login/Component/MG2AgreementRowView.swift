import UIKit
import SnapKit

/// 약관 동의 한 줄. 행 전체가 체크 영역(최소 44pt), 체크 원은 `accent`.
final class MG2AgreementRowView: UIControl {
    var onToggle: (() -> Void)?

    private let checkView = MG2CheckCircleView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var isChecked = false

    init(title: String, subtitle: String? = nil, isEmphasized: Bool = false) {
        super.init(frame: .zero)
        titleLabel.apply(isEmphasized ? .button : .row)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        subtitleLabel.apply(.footnote, color: DS.Color.sub)
        subtitleLabel.text = subtitle
        subtitleLabel.numberOfLines = 0
        subtitleLabel.isHidden = subtitle == nil
        if isEmphasized {
            backgroundColor = DS.Color.listTile
            roundCorners(DS.Radius.row)
        }
        configureLayout(inset: isEmphasized ? 16 : 0)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        isAccessibilityElement = true
        accessibilityLabel = [title, subtitle].compactMap { $0 }.joined(separator: ", ")
        accessibilityTraits = .button
        setChecked(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1 }
    }

    func setChecked(_ isChecked: Bool) {
        let animated = self.isChecked != isChecked
        self.isChecked = isChecked
        checkView.setDone(isChecked, color: DS.Color.accent, animated: animated)
        accessibilityValue = isChecked ? "동의함" : "동의 안 함"
    }

    private func configureLayout(inset: CGFloat) {
        let texts = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        texts.axis = .vertical
        texts.spacing = 2
        texts.isUserInteractionEnabled = false
        addSubviews(checkView, texts)

        checkView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(inset)
            $0.centerY.equalToSuperview()
        }
        texts.snp.makeConstraints {
            $0.leading.equalTo(checkView.snp.trailing).offset(12)
            $0.top.bottom.equalToSuperview().inset(max(inset, 10))
            $0.trailing.lessThanOrEqualToSuperview().inset(inset)
        }
        snp.makeConstraints { $0.height.greaterThanOrEqualTo(DS.Size.touch) }
    }

    @objc private func tapped() {
        onToggle?()
    }
}
