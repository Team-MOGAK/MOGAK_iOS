import UIKit

final class MG2PrimaryActionButton: UIButton {
    override var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        setTitleColor(.white, for: .normal)
        updateAppearance()
    }

    private func updateAppearance() {
        backgroundColor = isEnabled
            ? DesignSystemColor.signature.value
            : DesignSystemColor.gray3.value
    }
}
