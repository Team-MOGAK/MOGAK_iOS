import UIKit

final class MGCardContainerView: UIView {

    let contentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        applyMGCardStyle()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: MGSpacing.large),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: MGSpacing.large),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -MGSpacing.large),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -MGSpacing.large)
        ])
    }
}
