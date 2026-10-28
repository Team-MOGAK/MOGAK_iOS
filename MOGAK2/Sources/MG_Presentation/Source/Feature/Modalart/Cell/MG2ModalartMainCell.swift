//
//  MG2ModalartMainCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/11.
//

import UIKit
import SnapKit

/// 판 가운데 칸 (GoalCell, `.md-goal`). 판에서는 최종 목표, 모각 화면에서는 모각 이름. 흰 글자 · `shadow-goal`.
/// 캡션 11/700(0.85) · 이름 19/800(6자 넘으면 16), 위아래 10 · 좌우 8, 사이 6.
final class MG2ModalartMainCell: UICollectionViewCell {
    static let identifier = "MG2ModalartMainCell"

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.apply(.caption2, color: DS.Color.surface.withAlphaComponent(0.85))
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let goalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textColor = DS.Color.surface
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        // 칸 높이가 고정이라 넘치면 마지막 줄을 말줄임.
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
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
        goalLabel.font = .scaledCapped(.pretendard(.extraBold, size: title.count > 6 ? 16 : 19), relativeTo: .headline)
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
        stack.spacing = 6
        contentView.addSubview(stack)

        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.greaterThanOrEqualToSuperview().inset(10)
        }
    }
}
