//
//  MG2ModalartListCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/02.
//

import UIKit
import SnapKit

final class MG2ModalartListCell: UITableViewCell {
    static let identifier = String(describing: MG2ModalartListCell.self)

    private let modalartLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        contentView.addSubview(modalartLabel)

        modalartLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(16)
            $0.height.equalTo(53)
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
            modalartLabel.textColor = DesignSystemColor.black.value
        case .defaultTitle:
            modalartLabel.textColor = DesignSystemColor.gray3.value
        case .add:
            modalartLabel.textColor = DesignSystemColor.signature.value
        }
        modalartLabel.textAlignment = .left
    }
}
