import UIKit

final class MGPrimaryButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        titleLabel?.font = MGFont.button()
        setTitleColor(.white, for: .normal)
        backgroundColor = MGColor.primary
        layer.cornerRadius = MGCornerRadius.medium
        contentEdgeInsets = UIEdgeInsets(
            top: MGSpacing.medium,
            left: MGSpacing.large,
            bottom: MGSpacing.medium,
            right: MGSpacing.large
        )
    }
}
