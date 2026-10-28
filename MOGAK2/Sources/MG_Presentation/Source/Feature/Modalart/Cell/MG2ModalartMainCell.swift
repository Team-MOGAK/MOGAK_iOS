//
//  MG2ModalartMainCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/11.
//

import UIKit
import SnapKit

/// 판 가운데 칸 (GoalCell). 판에서는 최종 목표, 모각 화면에서는 모각 이름. 흰 글자 · `shadow-goal`.
final class MG2ModalartMainCell: UICollectionViewCell {
    static let identifier = "MG2ModalartMainCell"

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.apply(.caption1, color: DS.Color.surface.withAlphaComponent(0.85))
        label.textAlignment = .center
        return label
    }()

    private let goalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = DS.Color.surface
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.roundCorners(DS.Radius.cell)
        layer.apply(.goal)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 이름이 6자를 넘으면 16pt, 아니면 19pt.
    func configure(title: String, color: String, caption: String? = nil) {
        goalLabel.text = title
        goalLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .pretendard(.extraBold, size: title.count > 6 ? 16 : 19), maximumPointSize: 26)
        captionLabel.text = caption
        captionLabel.isHidden = caption == nil
        contentView.backgroundColor = DS.Moak.displayColor(forServerHex: color)
        contentView.isAccessibilityElement = true
        contentView.accessibilityLabel = [caption, title.replacingOccurrences(of: "\n", with: " ")].compactMap { $0 }.joined(separator: ", ")
        contentView.accessibilityTraits = .button
    }

    private func configureLayout() {
        let stack = UIStackView(arrangedSubviews: [captionLabel, goalLabel])
        stack.axis = .vertical
        stack.spacing = 4
        contentView.addSubview(stack)

        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }
}
