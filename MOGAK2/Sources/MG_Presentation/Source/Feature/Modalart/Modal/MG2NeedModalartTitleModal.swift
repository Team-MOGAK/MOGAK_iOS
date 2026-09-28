//
//  MG2NeedModalartTitleModal.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/20.
//
import UIKit
import SnapKit

///큰 목표가 없이 작은 목표 추가버튼을 눌렀을 때의 모달
final class MG2NeedModalartTitleModal: UIViewController {
    var onConfirm: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "작은 목표를 설정하기 전에\n큰 목표를 추가해주세요."
        label.textColor = DesignSystemColor.black.value
        label.numberOfLines = 2
        label.font = DesignSystemFont.semibold20L140.value
        return label
    }()

    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "내가 가장 원하는 목표를 적어주세요."
        label.textColor = DesignSystemColor.black.value.withAlphaComponent(0.6)
        label.numberOfLines = 1
        label.font = DesignSystemFont.regular14L150.value
        return label
    }()

    private lazy var okayButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.backgroundColor = DesignSystemColor.signature.value
        button.layer.cornerRadius = 10
        button.setTitleColor(DesignSystemColor.white.value, for: .normal)
        button.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        return button
    }()

    // MARK: - 확인 버튼 눌렀을떄
    @objc private func okayButtonTapped() {
        onConfirm?()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        view.backgroundColor = .white
        okayButton.addTarget(self, action: #selector(okayButtonTapped), for: .touchUpInside)
    }
}

// MARK: - 오토레이아웃 설정
extension MG2NeedModalartTitleModal {
    private func configureLayout() {
        view.addSubviews(titleLabel, subTitleLabel, okayButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(49)
            $0.centerX.equalToSuperview()
        }

        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }

        okayButton.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.centerX.equalToSuperview()
            $0.left.equalToSuperview().offset(30)
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(25)
        }
    }
}
