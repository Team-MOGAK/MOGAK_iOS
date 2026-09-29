import SnapKit
import UIKit

/// 원형 프로필 이미지. 바꿀 수 있으면 연필 배지를 달고 탭을 받는다.
final class MG2ProfileImageView: UIControl {
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    var isEditable = false {
        didSet { updateEditable() }
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.5 : 1 }
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = DesignSystemColor.gray2.value.cgColor
        return imageView
    }()

    private let editBadgeView = UIImageView(image: UIImage(named: "editIcon"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
        updateEditable()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.bounds.height / 2
    }

    private func configureLayout() {
        addSubviews(imageView, editBadgeView)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        editBadgeView.snp.makeConstraints { $0.trailing.bottom.equalToSuperview() }
    }

    private func updateEditable() {
        editBadgeView.isHidden = !isEditable
        isUserInteractionEnabled = isEditable
        isAccessibilityElement = true
        accessibilityLabel = "프로필 이미지"
        accessibilityTraits = isEditable ? .button : .image
    }
}
