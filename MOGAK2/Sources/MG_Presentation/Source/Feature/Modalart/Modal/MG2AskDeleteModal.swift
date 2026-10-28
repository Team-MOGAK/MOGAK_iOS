//
//  MG2AskDeleteModal.swift
//  MOGAK
//

import UIKit
import SnapKit

/// 삭제 확인 시트. 삭제만 `danger`, 거절은 ghost.
final class MG2AskDeleteModal: UIViewController {
    var onCancel: (() -> Void)?
    var onConfirm: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface

        let mascot = MG2MascotView(size: 72)
        mascot.pose = .sweat
        mascot.isInteractive = false
        let titleLabel = UILabel()
        titleLabel.apply(.title2)
        titleLabel.numberOfLines = 0
        titleLabel.text = "정말 삭제할까요?"
        titleLabel.textAlignment = .center
        titleLabel.accessibilityTraits = .header
        let subTitleLabel = UILabel()
        subTitleLabel.apply(.paragraph, color: DS.Color.sub)
        subTitleLabel.numberOfLines = 0
        subTitleLabel.text = "삭제하면 다시 되살릴 수 없어요"
        subTitleLabel.textAlignment = .center

        let deleteButton = MG2PrimaryActionButton()
        deleteButton.setTitle("삭제하기", for: .normal)
        deleteButton.backgroundColor = DS.Color.danger
        deleteButton.addAction(UIAction { [weak self] _ in self?.onConfirm?() }, for: .touchUpInside)
        let cancelButton = MG2PrimaryActionButton(style: .ghost)
        cancelButton.setTitle("그대로 둘게요", for: .normal)
        cancelButton.addAction(UIAction { [weak self] _ in self?.onCancel?() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [mascot, titleLabel, subTitleLabel, deleteButton, cancelButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(14, after: subTitleLabel)
        stack.setCustomSpacing(4, after: deleteButton)
        view.addSubview(stack)
        // `.md-sheet` 위 16 · 좌우 20 · 아래 20 (시트 높이는 내용에 맞춤)
        stack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.bottom.lessThanOrEqualToSuperview().inset(DS.Space.sheet)
        }
        deleteButton.snp.makeConstraints {
            $0.width.equalTo(stack)
            $0.height.equalTo(DS.Size.button)
        }
    }
}
