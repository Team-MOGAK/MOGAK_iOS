//
//  MG2EmptyMogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/04.
//

import UIKit
import SnapKit

///비어있는 모각 Cell
final class MG2EmptyMogakCell: UICollectionViewCell {
    static let identifier = "MG2EmptyMogakCell"

    private lazy var goalLabel: MG2PaddingLabel = {
        let label = MG2PaddingLabel(top: 6, bottom: 6, left: 12, right: 12)
        label.text = "작은목표"
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = DesignSystemColor.gray5.value
        label.backgroundColor = DesignSystemColor.gray2.value
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textAlignment = .center
        return label
    }()

    private lazy var addImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "plus.circle.fill")
        imageView.image = image
        imageView.tintColor = DesignSystemColor.gray2.value
        return imageView
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
}

// MARK: - 오토레이아웃 잡기
extension MG2EmptyMogakCell {
    private func configureLayout() {
        addSubviews(goalLabel, addImage)

        goalLabel.snp.makeConstraints {
            $0.width.equalTo(73)
            $0.height.equalTo(26)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
        }

        addImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(goalLabel.snp.bottom).offset(20)
            $0.size.equalTo(40)
        }
    }
}
