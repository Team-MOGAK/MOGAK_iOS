//
//  MG2MogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/10.
//

import UIKit
import SnapKit

/// 판 3×3의 모각 칸 (MoakCell). 태그 · 이름, ⋯로 모각 설정.
final class MG2MogakCell: UICollectionViewCell {
    static let identifier: String = "MG2MogakCell"
    private var onSettingsTap: (() -> Void)?

    // TODO(server): 이번 주 진척 API가 생기면 아래에서 모각 색(bg)으로 차오르는 칸과 % 표시.
    private let tagLabel = MG2TagLabel()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.apply(.subhead)
        label.numberOfLines = 2
        return label
    }()

    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)), for: .normal)
        button.tintColor = DS.Color.ghost
        button.accessibilityLabel = "모각 설정"
        button.addTarget(self, action: #selector(settingIconTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.backgroundColor = DS.Color.surface
        contentView.roundCorners(DS.Radius.cell)
        layer.apply(.card)
        isAccessibilityElement = false
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with mogak: MG2ModalartMogakItemEntity, onSettingsTap: @escaping () -> Void) {
        self.onSettingsTap = onSettingsTap
        tagLabel.configure(text: mogak.category.name, moak: DS.Moak.from(hex: mogak.color))
        nameLabel.text = mogak.title
        contentView.isAccessibilityElement = true
        contentView.accessibilityLabel = "\(mogak.title) 모각 열기, \(mogak.category.name)"
        contentView.accessibilityTraits = .button
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.numberOfLines = bounds.height < MG2MandalaGrid.singleLineCellHeight ? 1 : 2
    }

    override var isHighlighted: Bool {
        didSet {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            UIView.animate(withDuration: 0.15) { self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity }
        }
    }

    @objc private func settingIconTapped() {
        onSettingsTap?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSettingsTap = nil
    }

    private func configureLayout() {
        contentView.addSubviews(tagLabel, nameLabel, settingsButton)

        tagLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(12)
            $0.trailing.lessThanOrEqualTo(settingsButton.snp.leading)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
        }
        settingsButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(DS.Size.touch)
        }
    }
}
