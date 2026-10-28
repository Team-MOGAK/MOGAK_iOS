import UIKit
import SnapKit

final class MG2ColorSelectionCell: UICollectionViewCell {
    static let identifier = String(describing: MG2ColorSelectionCell.self)

    // 색 원 40 · 고른 표시 흰 점 24. 누르는 영역(44)은 셀 크기가 맡는다.
    private static let swatchSize: CGFloat = 40
    private static let dotSize: CGFloat = 24

    private let colorView = UIView()
    private let innerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            innerView.backgroundColor = isSelected ? DS.Color.surface : .clear
            accessibilityTraits = isSelected ? [.button, .selected] : .button
        }
    }

    /// 서버 색 값을 화면 색(모각 팔레트)으로 그린다.
    func configure(serverHex: String, accessibilityName: String) {
        colorView.backgroundColor = DS.Moak.displayColor(forServerHex: serverHex)
        isAccessibilityElement = true
        accessibilityLabel = accessibilityName
    }

    private func configureLayout() {
        colorView.layer.cornerRadius = Self.swatchSize / 2
        colorView.clipsToBounds = true
        innerView.layer.cornerRadius = Self.dotSize / 2
        innerView.clipsToBounds = true

        contentView.addSubview(colorView)
        colorView.addSubview(innerView)

        colorView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Self.swatchSize)
        }

        innerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Self.dotSize)
        }
    }
}
