//
//  MG2JogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/22.
//

import UIKit
import SnapKit

/// 루틴으로 설정되지 않는 조각
final class MG2JogakCell: UICollectionViewCell {
    static let identifier: String = "MG2JogakCell"

    /// 이행 내용 label
    private lazy var goalContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 16)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = DesignSystemColor.white.value
        layer.cornerRadius = 15
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        goalContentLabel.text = title
    }
}

extension MG2JogakCell {
    /// 레이아웃 잡기
    private func configureLayout() {
        addSubviews(goalContentLabel)

        goalContentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
