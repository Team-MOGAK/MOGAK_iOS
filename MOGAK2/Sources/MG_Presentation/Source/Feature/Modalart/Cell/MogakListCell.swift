//
//  MogakListCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/12/07.
//

import Foundation
import UIKit
import SnapKit

/// 모각 리스트(세부목표 화면에서 상단에 있는 모각 리스트)
class MogakListCell: UICollectionViewCell {
    static let identifier = "MogakListCell"
    /// 모각 제목 text(title label에 들어갈 내용)
    var mogakTitle: String = ""
    
    /// 모각 제목 label
    var titleLabel: UILabel!
    /// 그 아래 파란색 바텀 바
    var bottomBar: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 레이아웃 잡기
    /// 레이아웃 잡기
    func configureLayout() {
        titleLabel = UILabel()
        bottomBar = UIView()
        
        self.addSubviews(titleLabel, bottomBar)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        bottomBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.width.equalToSuperview()
            make.height.equalTo(3)
        }
    }
    
    //MARK: - 해당 모각이 선택됬을 경우
    /// 해당 모각이 선택됬을 경우(바텀바의 색상을 변경해줘야 함)
    override var isSelected: Bool {
        didSet {
            if isSelected {
                bottomBar.backgroundColor = DesignSystemColor.signature.value
            } else {
                bottomBar.backgroundColor = .clear
            }
        }
    }
}
