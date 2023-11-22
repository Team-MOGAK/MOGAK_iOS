//
//  ListTableViewCell.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/16.
//

import UIKit
import SnapKit

class ListTableViewCell: UITableViewCell {
    weak var parentViewController: UIViewController?
    
    private let containerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor(red: 0.749, green: 0.765, blue: 0.831, alpha: 0.5).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()
    
    // 작은목표
    let smallGoalView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor(hex: "DDF7FF")
        return view
    }()
    
    let smallGoalLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    // 회차정보
    private let episodeView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor(hex: "F1F3FA")
        return view
    }()
    
    let episodeLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor(hex: "6E707B")
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    // 목표이름
    let titleLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor(hex: "24252E")
        label.font = UIFont.pretendard(.semiBold, size: 16)
        return label
    }()
    
    // 날짜
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023년 6월 5일"
        label.textColor = UIColor(hex: "808497")
        label.font = UIFont.pretendard(.regular, size: 14)
        
        return label
    }()
    
    private let ellipsisButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(hex: "6E707B")
        button.addTarget(self, action: #selector(ellipsisButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func ellipsisButtonTapped() {
        print("TAPPED")
        let alertController: UIAlertController
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정하기", style: .default) { _ in
            // Edit action
            let navigationController = UINavigationController(rootViewController: ConfirmEdittingSheetViewController())
            
            navigationController.isNavigationBarHidden = true
            
            //self.present(navigationController, animated: true, completion: nil)
            self.parentViewController?.present(navigationController, animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { _ in
            // Delete action
            let navigationController = UINavigationController(rootViewController: ConfirmDeletingFeedSheetViewController())
            
            navigationController.isNavigationBarHidden = true
            
            //self.present(navigationController, animated: true, completion: nil)
            self.parentViewController?.present(navigationController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel, handler: nil)
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.parentViewController?.present(alertController, animated: true, completion: nil)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(hex: "F1F3FA")
        configureContainerView()
        configureButton()
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(backColor: UIColor, titleText: String, statusText: String, categoryText: String, statusTextColor: UIColor) {
        smallGoalView.backgroundColor = backColor
        titleLabel.text = titleText
        smallGoalLabel.text = statusText
        episodeLabel.text = categoryText
        smallGoalLabel.textColor = statusTextColor
    }
    
    private func configureLabel() {
        containerView.addSubview(titleLabel)
        containerView.addSubviews(smallGoalLabel, episodeLabel)
        containerView.addSubview(dateLabel)
        
        titleLabel.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(16) //원래 46
            $0.leading.equalTo(containerView.snp.leading).offset(16)
        })
        
        smallGoalLabel.snp.makeConstraints({
            $0.centerX.equalTo(smallGoalView)
            $0.centerY.equalTo(smallGoalView)
        })
        
        episodeLabel.snp.makeConstraints({
            $0.centerX.equalTo(episodeView)
            $0.centerY.equalTo(episodeView)
        })
        
        dateLabel.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(80)
            $0.leading.equalTo(containerView.snp.leading).offset(16)
        })
    }
    
    private func configureButton() {
        containerView.addSubviews(smallGoalView, episodeView, ellipsisButton)
        
        smallGoalView.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(44)
            $0.leading.equalTo(containerView.snp.leading).offset(16)
            $0.width.equalTo(57)
            $0.height.equalTo(26)
        })
        
        episodeView.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(44)
            $0.leading.equalTo(smallGoalView.snp.trailing).offset(8)
            $0.width.equalTo(57)
            $0.height.equalTo(26)
        })
        
        ellipsisButton.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.top).offset(24)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-16)
            $0.width.equalTo(15)
            $0.height.equalTo(4)
        })
    }
    
    private func configureContainerView() {
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints({
            $0.top.equalTo(contentView.snp.top).offset(24)
            $0.leading.trailing.equalTo(contentView).inset(20)
            $0.height.equalTo(108)
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
