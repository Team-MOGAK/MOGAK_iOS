//
//  MG2NameCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/12.
//

import UIKit
import SnapKit

/// 고르는 목록 한 칸 (리스트 타일). 꺼짐 `list-tile`, 켜짐 `accent-tint` 바탕 + `accent-line` 2px 테두리.
class MG2NameCell: UITableViewCell {
    private let tileView = UIView()
    private let nameLabel = UILabel()
    private let checkView = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        tileView.roundCorners(DS.Radius.field)
        nameLabel.apply(.row)
        nameLabel.numberOfLines = 0
        checkView.tintColor = DS.Color.accentDeep
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, isChecked: Bool) {
        nameLabel.text = name
        checkView.isHidden = !isChecked
        tileView.backgroundColor = isChecked ? DS.Color.accentTint : DS.Color.listTile
        tileView.layer.borderWidth = isChecked ? 2 : 0
        tileView.layer.borderColor = DS.Color.accentLine.cgColor
        accessibilityLabel = name
        accessibilityTraits = isChecked ? [.button, .selected] : .button
    }

    private func configureLayout() {
        contentView.addSubview(tileView)
        tileView.addSubviews(nameLabel, checkView)

        tileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.height.greaterThanOrEqualTo(DS.Size.row)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(14)
            $0.trailing.lessThanOrEqualTo(checkView.snp.leading).offset(-8)
        }
        checkView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
