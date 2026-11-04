//
//  MG2ModalartMainCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/11.
//

import UIKit
import SnapKit

/// 판 가운데 칸 (GoalCell, `.md-goal`). 판에서는 최종 목표, 모각 화면에서는 모각 이름. 흰 글자 · `shadow-goal`.
/// 캡션 11/700(0.85) · 이름 19/800(6자 넘으면 16) · 이번 주 % 캡슐 12/700, 위아래 10 · 좌우 8, 사이 6.
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

    /// `.md-goal em`: 안쪽 2 8 · 흰색 20% 바탕 캡슐.
    private let percentLabel: MG2PaddingLabel = {
        let label = MG2PaddingLabel(top: 2, bottom: 2, left: 8, right: 8)
        label.font = .scaledCapped(.pretendard(.bold, size: 12), relativeTo: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = DS.Color.surface
        label.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        label.clipsToBounds = true
        label.isHidden = true
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
    func configure(title: String, color: String, caption: String? = nil, percent: Int? = nil) {
        goalLabel.text = title
        goalLabel.font = .scaledCapped(.pretendard(.extraBold, size: title.count > 6 ? 16 : 19), relativeTo: .headline)
        captionLabel.text = caption
        captionLabel.isHidden = caption == nil
        percentLabel.text = percent.map { "\($0)%" }
        percentLabel.isHidden = percent == nil
        contentView.backgroundColor = DS.Moak.displayColor(forServerHex: color)
        contentView.isAccessibilityElement = true
        contentView.accessibilityLabel = [caption, title.replacingOccurrences(of: "\n", with: " "), percent.map { "이번 주 \($0)퍼센트" }].compactMap { $0 }.joined(separator: ", ")
        contentView.accessibilityTraits = .button
    }

    private func configureLayout() {
        let stack = UIStackView(arrangedSubviews: [captionLabel, goalLabel, percentLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        contentView.addSubview(stack)

        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.greaterThanOrEqualToSuperview().inset(10)
        }
        goalLabel.snp.makeConstraints { $0.width.equalTo(stack) }
        captionLabel.snp.makeConstraints { $0.width.equalTo(stack) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        percentLabel.layer.cornerRadius = percentLabel.bounds.height / 2
    }
}
