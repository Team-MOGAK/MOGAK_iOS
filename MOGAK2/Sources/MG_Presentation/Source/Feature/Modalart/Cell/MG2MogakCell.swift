//
//  MG2MogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/10.
//

import UIKit
import SnapKit

/// 판 3×3의 모각 칸 (`.md-cell`): 가운데 정렬 태그 · 이름 15/700, 위아래 10 · 좌우 8, 사이 8. ⋯로 모각 설정.
final class MG2MogakCell: UICollectionViewCell {
    static let identifier: String = "MG2MogakCell"
    private var onSettingsTap: (() -> Void)?

    // TODO(server): 이번 주 진척 API가 생기면 아래에서 모각 색(bg)으로 차오르는 칸과 % 표시.
    private let tagLabel: MG2TagLabel = {
        let label = MG2TagLabel()
        // 칸 폭을 넘는 카테고리는 줄였다가 말줄임.
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.apply(.subhead)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        // 큰 글자에서 칸을 넘치면 이름이 먼저 줄어 말줄임된다.
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()

    /// 44pt 터치 영역, 점 세 개는 칸 안쪽 위 오른쪽 모서리(10pt)에.
    private lazy var settingsButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        configuration.baseForegroundColor = DS.Color.faint
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 10)
        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .trailing
        button.contentVerticalAlignment = .top
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
        contentView.accessibilityCustomActions = [UIAccessibilityCustomAction(name: "모각 설정") { [weak self] _ in
            self?.onSettingsTap?()
            return true
        }]
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
        let stack = UIStackView(arrangedSubviews: [tagLabel, nameLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        contentView.addSubviews(stack, settingsButton)

        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.greaterThanOrEqualToSuperview().inset(10)
        }
        nameLabel.snp.makeConstraints { $0.width.equalTo(stack) }
        settingsButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(DS.Size.touch)
        }
    }
}
