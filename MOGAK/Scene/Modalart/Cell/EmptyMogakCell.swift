//
//  EmptyMogakCellCollectionViewCell.swift
//  MOGAK
//
//  Created by 김라영 on 2023/10/04.
//

import UIKit
import SnapKit
import Then

///비어있는 모각 Cell
class EmptyMogakCell: UICollectionViewCell {
    static let identifier = "EmptyMogakCell"
    
    private lazy var goalLabel : UILabel = {
        let label = CustomPaddingLabel(top: 6, bottom: 6, left: 12, right: 12)
        label.text = "작은목표"
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = DesignSystemColor.gray5.value
        label.backgroundColor = DesignSystemColor.gray2.value
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addBtn : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "mogakPlusBtn"), for: .normal)
        btn.contentMode = .scaleToFill
//        btn.addTarget(self, action: #selector(addBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        print(#fileID, #function, #line, "- emptyMogakCell⭐️")
        self.backgroundColor = DesignSystemColor.white.value
        self.layer.cornerRadius = 15
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - +버튼을 눌렀을 경우
    @objc private func addBtnTapped() {
        print(#fileID, #function, #line, "- addBtnTapped⭐️")
    }
    
    
}

//MARK: - 오토레이아웃 잡기
extension EmptyMogakCell {
    private func configureLayout() {
        self.addSubviews(goalLabel, addBtn)
        
        goalLabel.snp.makeConstraints {
            $0.width.equalTo(73)
            $0.height.equalTo(26)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
            $0.bottom.equalTo(self.addBtn.snp.top).offset(-22)
        }
        
        addBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50)
        }
    }
}
