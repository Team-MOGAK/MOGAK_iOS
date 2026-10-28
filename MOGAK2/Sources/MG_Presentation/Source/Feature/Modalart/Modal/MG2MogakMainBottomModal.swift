//
//  MG2MogakMainBottomModal.swift
//  MOGAK
//

import UIKit
import SnapKit

/// 모각 설정 시트: 태그 · 이름, 주 버튼 "모각 수정", 아래 `danger` "모각 삭제".
final class MG2MogakMainBottomModal: UIViewController {
    private let selectedMogak: MG2ModalartMogakItemEntity
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    var onClose: (() -> Void)?

    init(mogak: MG2ModalartMogakItemEntity) {
        selectedMogak = mogak
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Color.surface

        let header = MG2SheetHeaderView(title: "모각")
        header.onClose = { [weak self] in self?.onClose?() }
        let tag = MG2TagLabel()
        tag.configure(text: selectedMogak.category.name, moak: DS.Moak.from(hex: selectedMogak.color))
        let titleLabel = UILabel()
        titleLabel.apply(.title2)
        titleLabel.numberOfLines = 0
        titleLabel.text = selectedMogak.title

        let editButton = MG2PrimaryActionButton()
        editButton.setTitle("모각 수정", for: .normal)
        editButton.addAction(UIAction { [weak self] _ in self?.onEdit?() }, for: .touchUpInside)
        let deleteButton = MG2PrimaryActionButton(style: .danger)
        deleteButton.setTitle("모각 삭제", for: .normal)
        deleteButton.addAction(UIAction { [weak self] _ in self?.onDelete?() }, for: .touchUpInside)

        view.addSubviews(header, tag, titleLabel, editButton, deleteButton)
        header.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        tag.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom).offset(14)
            $0.leading.equalToSuperview().inset(DS.Space.sheet)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(tag.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
        }
        editButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(DS.Space.sheet)
            $0.height.equalTo(DS.Size.button)
        }
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(DS.Size.touch)
            $0.bottom.lessThanOrEqualToSuperview().inset(DS.Space.sheet)
        }
    }
}
