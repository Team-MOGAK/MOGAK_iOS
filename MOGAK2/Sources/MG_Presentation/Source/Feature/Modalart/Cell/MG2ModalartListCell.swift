//
//  MG2ModalartListCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

/// 모다라트 목록 한 줄 (56pt).
final class MG2ModalartListCell: UITableViewCell {
    static let identifier = String(describing: MG2ModalartListCell.self)

    private let modalartLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        let background = UIView()
        background.backgroundColor = DS.Color.listTile
        selectedBackgroundView = background
        modalartLabel.apply(.row)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        contentView.addSubview(modalartLabel)

        modalartLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(DS.Space.cardX)
            $0.centerY.equalToSuperview()
        }
    }

    enum Style {
        case normal
        case defaultTitle
        case add
    }

    func configure(title: String, style: Style) {
        modalartLabel.text = title
        switch style {
        case .normal:
            modalartLabel.textColor = DS.Color.ink
            modalartLabel.font = T.row.font
        case .defaultTitle:
            modalartLabel.textColor = DS.Color.muted
            modalartLabel.font = T.row.font
        case .add:
            modalartLabel.textColor = DS.Color.accentDeep
            modalartLabel.font = T.button.font
        }
        accessibilityTraits = .button
    }
}
