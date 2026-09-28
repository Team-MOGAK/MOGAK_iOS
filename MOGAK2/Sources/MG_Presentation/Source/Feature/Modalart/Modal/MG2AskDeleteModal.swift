//
//  MG2AskDeleteModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/14.
//

import UIKit
import SnapKit

///진짜 삭제할건지 물어보는 모달
final class MG2AskDeleteModal: UIViewController {
    var onCancel: (() -> Void)?
    var onConfirm: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "정말 삭제하시겠어요?"
        label.textColor = DesignSystemColor.black.value
        label.numberOfLines = 1
        label.font = DesignSystemFont.semibold20L140.value
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "다시 복원할 수 없어요 :(\n신중하게 선택해주세요"
        label.textColor = DesignSystemColor.black.value.withAlphaComponent(0.6)
        label.numberOfLines = 2
        label.font = DesignSystemFont.regular14L150.value
        return label
    }()

    private lazy var noButton: UIButton = {
        let button = UIButton()
        button.setTitle("아니요", for: .normal)
        button.backgroundColor = DesignSystemColor.signatureBag.value
        button.layer.cornerRadius = 10
        button.setTitleColor(DesignSystemColor.signature.value, for: .normal)
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var yesButton: UIButton = {
        let button = UIButton()
        button.setTitle("네", for: .normal)
        button.backgroundColor = DesignSystemColor.signature.value
        button.layer.cornerRadius = 10
        button.setTitleColor(DesignSystemColor.white.value, for: .normal)
        button.titleLabel?.font = DesignSystemFont.medium16L100.value
        button.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.spacing = 10
        buttonStackView.distribution = .fillEqually
        buttonStackView.addArrangedSubview(noButton)
        buttonStackView.addArrangedSubview(yesButton)
        return buttonStackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        view.backgroundColor = .white
    }

    @objc private func noButtonTapped() {
        onCancel?()
    }

    @objc private func yesButtonTapped() {
        onConfirm?()
    }
}

// MARK: - 오토레이아웃 설정
extension MG2AskDeleteModal {
    private func configureLayout() {
        view.addSubviews(titleLabel, subTitleLabel, buttonStackView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(49)
            $0.centerX.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }

        buttonStackView.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(subTitleLabel.snp.bottom)
                .offset(32)
            $0.centerX.equalToSuperview()
        }
    }
}
