//
//  MG2NeedModalartTitleModal.swift
//  MOGAK
//

import UIKit
import SnapKit

/// 최종 목표 없이 모각을 만들려 할 때의 안내 시트.
final class MG2NeedModalartTitleModal: UIViewController {
    var onConfirm: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface

        let mascot = MG2MascotView(size: 72)
        mascot.pose = .think
        mascot.isInteractive = false
        let titleLabel = UILabel()
        titleLabel.apply(.title2)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = "모각을 만들기 전에\n최종 목표를 먼저 정해 주세요"
        titleLabel.accessibilityTraits = .header
        let subTitleLabel = UILabel()
        subTitleLabel.apply(.paragraph, color: DS.Color.sub)
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .center
        subTitleLabel.text = "가운데 칸에 들어갈 최종 목표 하나면 시작할 수 있어요"

        let closeButton = MG2PrimaryActionButton()
        closeButton.setTitle("닫기", for: .normal)
        closeButton.addAction(UIAction { [weak self] _ in self?.onConfirm?() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [mascot, titleLabel, subTitleLabel, closeButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(14, after: subTitleLabel)
        view.addSubview(stack)
        // `.md-sheet` 위 16 · 좌우 20 · 아래 20 (시트 높이는 내용에 맞춤)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.bottom.lessThanOrEqualToSuperview().inset(DS.Space.sheet)
        }
        closeButton.snp.makeConstraints {
            $0.width.equalTo(stack)
            $0.height.equalTo(DS.Size.button)
        }
    }
}
