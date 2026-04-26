//
//  MogakCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/10.
//

import Foundation
import UIKit
import SnapKit

/// 사용자가 목표를 설정했을때 생성되는 모각
class MogakCell: UICollectionViewCell {
    weak var delegate: MogakSettingButtonTappedDelegate?
    
    static let identifier: String = "MogakCell"
    var mogakCellData: DetailMogakData = DetailMogakData(mogakId: 0, title: "", bigCategory: MainCategory(id: 0, name: ""), smallCategory: "", color: "")
    
    private lazy var goalCategoryLabel: CustomPaddingLabel = {
        let label = CustomPaddingLabel(top: 6, bottom: 6, left: 12, right: 12)
        label.numberOfLines = 0
        label.text = self.mogakCellData.bigCategory.name
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var goalContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = mogakCellData.title
        label.textColor = DesignSystemColor.black.value
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var settingIcon: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "settingIcon"), for: .normal)
        button.addTarget(self, action: #selector(settingIconTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = DesignSystemColor.white.value
        self.layer.cornerRadius = 15
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 셀 안의 내용을 셋팅하는 부분
    func cellDataSetting() {
        //카테고리
        self.goalCategoryLabel.text = mogakCellData.bigCategory.name
        //카테고리의 배경색
        self.goalCategoryLabel.backgroundColor = UIColor(hex: mogakCellData.color ?? "475FFD").withAlphaComponent(0.1)
        //카테고리의 글자색
        self.goalCategoryLabel.textColor = UIColor(hex: mogakCellData.color ?? "475FFD")
        
        //실제 이루고자하는 내용
        self.goalContentLabel.text = mogakCellData.title
    }
    
    //MARK: - 모각세팅으로 이동하는 부분
    @objc func settingIconTapped() {
        delegate?.cellButtonTapped(mogakData: self.mogakCellData)
    }
}

//MARK: - 오토레이아웃 잡기
extension MogakCell {
    private func configureLayout() {
        self.addSubviews(goalCategoryLabel, goalContentLabel, settingIcon)
        
        goalCategoryLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
        }
        
        goalContentLabel.snp.makeConstraints {
            $0.top.equalTo(goalCategoryLabel.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        settingIcon.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
    }
}
