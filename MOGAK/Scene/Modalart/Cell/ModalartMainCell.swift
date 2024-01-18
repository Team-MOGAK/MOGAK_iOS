//
//  ModartMainCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/11.
//

import Foundation
import UIKit
import SnapKit

/// 모다라트 정중앙에 들어가는 Cell
class ModalartMainCell: UICollectionViewCell {
    static let identifier = "ModalartMainCell"
    var mainBackgroundColor: String = ""
    //mainLabelText같은 경우에 모다라트가 생성되었다면 해당 모다라트의 목표가 없다면 큰 목표추가라는 문구가 들어간다
    var mainLabelText: String = ""
    
    private lazy var goalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = DesignSystemColor.white.value
        label.font = UIFont.pretendard(.semiBold, size: 16)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellDataSetting() {
        self.layer.cornerRadius = 15
        goalLabel.text = mainLabelText
        self.backgroundColor = UIColor(hex: mainBackgroundColor)
        configureLayout()
    }
    
}

//MARK: - 오토레이아웃 잡기
extension ModalartMainCell {
    private func configureLayout() {
        self.addSubview(goalLabel)
        
        goalLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
