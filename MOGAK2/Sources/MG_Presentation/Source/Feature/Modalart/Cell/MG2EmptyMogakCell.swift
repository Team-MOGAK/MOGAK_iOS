//
//  MG2EmptyMogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/04.
//

import UIKit
import SnapKit

/// 빈 모각 칸 (EmptyCell). 다음에 채울 칸 하나만 `accent-dash` 점선 · `accent-tint` 바탕 · "모각 추가",
/// 나머지는 `border` 점선 + `ghost` 플러스만.
final class MG2EmptyMogakCell: UICollectionViewCell {
    static let identifier = "MG2EmptyMogakCell"

    private let dashLayer = CAShapeLayer()
    private let plusImageView = UIImageView(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)))
    private let label: UILabel = {
        let label = UILabel()
        label.apply(.footnoteBold, color: DS.Color.accentDeep)
        label.text = "모각 추가"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        dashLayer.fillColor = nil
        dashLayer.lineWidth = 2
        dashLayer.lineDashPattern = [6, 5]
        contentView.layer.addSublayer(dashLayer)
        contentView.roundCorners(DS.Radius.cell)

        let stack = UIStackView(arrangedSubviews: [plusImageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.center.equalToSuperview() }
        contentView.isAccessibilityElement = true
        contentView.accessibilityLabel = "빈 칸에 모각 추가"
        contentView.accessibilityTraits = .button
        configure(isSuggested: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashLayer.path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 1, dy: 1), cornerRadius: DS.Radius.cell).cgPath
    }

    func configure(isSuggested: Bool, label text: String = "모각 추가") {
        label.text = text
        contentView.accessibilityLabel = "빈 칸에 \(text)"
        dashLayer.strokeColor = (isSuggested ? DS.Color.accentDash : DS.Color.border).cgColor
        contentView.backgroundColor = isSuggested ? DS.Color.accentTint : .clear
        plusImageView.tintColor = isSuggested ? DS.Color.accentDeep : DS.Color.ghost
        label.isHidden = !isSuggested
    }
}
