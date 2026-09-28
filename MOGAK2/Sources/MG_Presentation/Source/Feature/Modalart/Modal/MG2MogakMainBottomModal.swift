//
//  MG2MogakMainBottomModal.swift
//  MOGAK
//
//  Created by 김라영 on 2024/02/19.
//

import UIKit
import SnapKit

/// 조각 페이지에서 중앙 모각 탭시 올라오는 모각 뷰
final class MG2MogakMainBottomModal: UIViewController {
    private let selectedMogak: MG2ModalartMogakItemEntity
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?

    init(mogak: MG2ModalartMogakItemEntity) {
        selectedMogak = mogak
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var categoryLabel: MG2PaddingLabel = {
        let label = MG2PaddingLabel(top: 4, bottom: 4, left: 10, right: 10)
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold14L150.value
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()

    private lazy var mogakTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = DesignSystemFont.medium18L140.value
        return label
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.backgroundColor = DesignSystemColor.signatureBag.value
        button.layer.cornerRadius = 10
        button.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정", for: .normal)
        button.backgroundColor = DesignSystemColor.signature.value
        button.layer.cornerRadius = 10
        button.setTitleColor(DesignSystemColor.white.value, for: .normal)
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(editButton)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureContent()
        configureLayout()
        view.backgroundColor = .white
    }

    private func configureContent() {
        categoryLabel.text = selectedMogak.category.name
        categoryLabel.textColor = UIColor(hex: selectedMogak.color ?? "#475FFD")
        categoryLabel.backgroundColor = UIColor(hex: selectedMogak.color ?? "#475FFD").withAlphaComponent(0.1)

        mogakTitleLabel.text = selectedMogak.title
    }

    // MARK: - 모각 delete버튼 클릭시
    @objc private func deleteButtonTapped() {
        onDelete?()
    }

    // MARK: - 모각 수정
    @objc private func editButtonTapped() {
        onEdit?()
    }
}

extension MG2MogakMainBottomModal {
    private func configureLayout() {
        view.addSubviews(categoryLabel, mogakTitleLabel, buttonStackView)

        categoryLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(44)
            $0.leading.equalToSuperview().offset(20)
        }

        mogakTitleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
        }

        buttonStackView.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.top.equalTo(mogakTitleLabel.snp.bottom).offset(13)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
