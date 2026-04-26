//
//  JogakDetailCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/06.
//

import UIKit
import SnapKit

protocol JogakDetailDelegate {
    func ellipsisTapped()
}

class JogakDetailCell: UITableViewCell {
    
    var jogakDelegate: JogakDetailDelegate?
    
    private let container = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.shadowColor = UIColor.black.cgColor // 색깔
        $0.layer.masksToBounds = false  // 내부에 속한 요소들이 UIView 밖을 벗어날 때, 잘라낼 것인지. 그림자는 밖에 그려지는 것이므로 false 로 설정
        $0.layer.shadowOffset = CGSize(width: 0, height: 4) // 위치조정
        $0.layer.shadowRadius = 5 // 반경
        $0.layer.shadowOpacity = 0.3 // alpha값
    }
    
    private let square = UIImageView().then {
        $0.image = UIImage(named: "squareButtonOn")
    }
    
    private let title = UILabel().then {
        $0.text = "한 줄까지 쓸 수 있어요."
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.medium, size: 16)
    }
    
    private let duration = UILabel().then {
        $0.text = "1시간 20분"
        $0.textColor = UIColor(hex: "6E707B")
        $0.font = UIFont.pretendard(.regular, size: 14)
    }
    
    private let userImage = UIImageView().then {
        $0.image = UIImage(named: "default")
        $0.layer.cornerRadius = 10
    }
    
    private let contentLabel = UILabel().then {
        $0.text = "자기 전 기획 아티클 읽기 3일째, 오늘은 BM 관련 아티클에서 인상 깊은 내용이 있어 메모하며 읽어보았다. 특히, 학교에서 알려주신 책을 도서관에서 ..."
        $0.textColor = UIColor(hex: "6E707B")
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.numberOfLines = 4
    }
    
    private lazy var elipsisButton = UIButton().then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        $0.tintColor = UIColor(hex: "6E707B")
        $0.addTarget(self, action: #selector(ellipsisButtonTapped), for: .touchUpInside)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(hex: "F1F3FA")
        self.contentView.isUserInteractionEnabled = false
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.addSubview(container)
        [square, title, duration, userImage, contentLabel, elipsisButton].forEach({container.addSubview($0)})
        userImage.layer.cornerRadius = 10
        
        container.snp.makeConstraints({
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-12)
        })
        
        square.snp.makeConstraints({
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalToSuperview().multipliedBy(0.057)
            $0.height.equalToSuperview().multipliedBy(0.13)
        })
        
        title.snp.makeConstraints({
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(self.square.snp.trailing).offset(12)
        })
        
        duration.snp.makeConstraints({
            $0.top.equalTo(self.title.snp.bottom).offset(4)
            $0.leading.equalTo(self.square.snp.trailing).offset(12)
        })
        
        userImage.snp.makeConstraints({
            $0.top.equalTo(self.duration.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(48)
            $0.width.equalToSuperview().multipliedBy(0.18)
            $0.height.equalToSuperview().multipliedBy(0.42)
        })
        
        contentLabel.snp.makeConstraints({
            $0.top.equalTo(self.duration.snp.bottom).offset(8)
            $0.leading.equalTo(self.userImage.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
        })
        
        elipsisButton.snp.makeConstraints({
            $0.top.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalToSuperview().multipliedBy(0.043)
            $0.height.equalToSuperview().multipliedBy(0.03)
        })
    }
    
    @objc private func ellipsisButtonTapped() {
        print("탭드")
        self.jogakDelegate?.ellipsisTapped()
    }
    
}
