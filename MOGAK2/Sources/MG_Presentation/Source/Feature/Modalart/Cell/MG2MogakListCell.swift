//
//  MG2MogakListCell.swift
//  MOGAK
//

import UIKit
import SnapKit

/// 모각 상세 위쪽 모각 고르기 칩 (`.md-chip`). 켜짐은 그 모각 색 deep.
final class MG2MogakListCell: UICollectionViewCell {
    static let identifier = "MG2MogakListCell"
    static let font = T.footnoteBold.font

    private let titleLabel = UILabel()
    private var moak = DS.Moak.blue

    override init(frame: CGRect) {
        super.init(frame: .zero)
        titleLabel.font = Self.font
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        contentView.layer.cornerRadius = DS.Size.chip / 2
        isAccessibilityElement = true
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, color: String?) {
        titleLabel.text = title
        moak = DS.Moak.from(hex: color)
        accessibilityLabel = title
        updateAppearance()
    }

    static func size(for title: String) -> CGSize {
        CGSize(width: ceil((title as NSString).size(withAttributes: [.font: font]).width) + 28, height: DS.Size.chip)
    }

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    private func updateAppearance() {
        contentView.backgroundColor = isSelected ? moak.deep : DS.Color.fill
        titleLabel.textColor = isSelected ? DS.Color.surface : DS.Color.ink2
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }
}
