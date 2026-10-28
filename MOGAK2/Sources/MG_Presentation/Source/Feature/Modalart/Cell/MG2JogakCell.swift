//
//  MG2JogakCell.swift
//  MOGAK
//

import UIKit
import SnapKit

/// 모각 판의 조각 칸 (`.md-cell`): `surface` · 모서리 22 · `shadow-card`, 가운데 정렬 이름 15/700.
/// 루틴 조각은 위에 모각 색 태그(루틴 요일)를 단다.
class MG2JogakCell: UICollectionViewCell {
    static let identifier: String = "MG2JogakCell"

    let tagLabel = MG2TagLabel()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.apply(.subhead)
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.backgroundColor = DS.Color.surface
        contentView.roundCorners(DS.Radius.cell)
        layer.apply(.card)
        tagLabel.isHidden = true

        let stack = UIStackView(arrangedSubviews: [tagLabel, nameLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.greaterThanOrEqualToSuperview().inset(10)
        }
        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = .button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.numberOfLines = bounds.height < MG2MandalaGrid.singleLineCellHeight ? (tagLabel.isHidden ? 2 : 1) : 3
    }

    override var isHighlighted: Bool {
        didSet {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            UIView.animate(withDuration: 0.15) { self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity }
        }
    }

    func configure(title: String) {
        nameLabel.text = title
        tagLabel.isHidden = true
        contentView.accessibilityLabel = "\(title) 조각, 오늘만"
    }
}
