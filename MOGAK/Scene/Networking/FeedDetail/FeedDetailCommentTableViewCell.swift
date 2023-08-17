//
//  FeedDetailCommentTableViewCell.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/08/14.
//

import UIKit
import SnapKit
import Then
import ReusableKit


class FeedDetailCommentTableViewCell: UITableViewCell {

    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
//    }
    
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
////        configureProfile()
////        configureBody()
//        initCell()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    
    // MARK: - CELL 구성요소
    // 프사
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "person.circle.fill")
        //imageView.image = UIImage(named: "cuteBokdol")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
        return imageView
    }()
    
    // 이름
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.pretendard(.semiBold, size: 14)
        label.textColor = UIColor(hex: "24252E")
        return label
    }()
    
    // 댓글
    private let commentText: UILabel = UILabel().then {
        $0.textColor = UIColor(hex: "200E04")
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.numberOfLines = 0
        $0.alpha = 0.9
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        paragraphStyle.lineBreakMode = .byCharWrapping
        //paragraphStyle.lineBreakStrategy = .hangulWordPriority
        $0.attributedText = NSMutableAttributedString(
            string: "",
            attributes: [.paragraphStyle: paragraphStyle]
        )
    }
    
    private func initCell() {
        contentView.addSubviews(profileImageView, nameLabel, commentText)
        
        profileImageView.snp.makeConstraints({
            $0.top.left.equalToSuperview()
            $0.width.height.equalTo(36)
        })
        
        nameLabel.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.left.equalTo(profileImageView.snp.right).offset(8)
            $0.right.equalToSuperview()
        })
        
        commentText.snp.makeConstraints({
            $0.left.equalTo(profileImageView.snp.right).offset(8)
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.bottom).offset(-24)
        })
    }
    
    func configureCell(profileImage: String, name: String, comment: String) {
        self.nameLabel.text = name
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        self.profileImageView.image = UIImage(named: profileImage)
        profileImageView.layer.cornerRadius = 18

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        paragraphStyle.lineBreakMode = .byCharWrapping
        self.commentText.attributedText = NSMutableAttributedString(
            string: comment,
            attributes: [.paragraphStyle: paragraphStyle]
        )
    }
}
