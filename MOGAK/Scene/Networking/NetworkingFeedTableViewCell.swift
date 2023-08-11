//
//  NetworkingFeedTableViewCell.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/07/21.
//

import UIKit
import SnapKit

class NetworkingFeedTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureProfile()
        configureBody()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    // MARK: - HEADER
    // 프로필 이미지, 이름, 카테고리, 팔로잉유무 버튼
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let profileContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.text = "이재혁"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        label.textColor = UIColor(hex: "24252E")
        return label
    }()
    
    private let categoryLabel : UILabel = {
        let label = UILabel()
        label.text = "서비스기획자/PM"
        label.font = UIFont.pretendard(.regular, size: 12)
        label.textColor = UIColor(hex: "6E707B")
        return label
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        // 이미지 설정
        imageView.image = UIImage(systemName: "person.circle.fill") // 이미지 이름을 적절히 바꾸세요.
        // 이미지의 컨텐트 모드 설정 (옵션)
        imageView.contentMode = .scaleAspectFit
        // 이미지뷰 크기 설정 (옵션)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        //imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        imageView.tintColor = .systemBlue
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var isFollowing: Bool = false
    
    private let followingButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.pretendard(.semiBold, size: 14)
        button.setTitle("팔로잉", for: .normal)
        button.setTitleColor(UIColor(hex: "6E707B"), for: .normal)
        button.backgroundColor = UIColor(hex: "EEF0F8")
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        button.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func followingButtonTapped() {
        isFollowing.toggle()
        print("Tapped") // 디버깅용
        
        if isFollowing {
            followingButton.setTitle("팔로잉", for: .normal)
        } else {
            followingButton.setTitle("팔로우", for: .normal)
        }
    }
    
    private func configureProfile() {
        // Cell contentView에 top add
        contentView.addSubview(topContainerView)
        
        topContainerView.snp.makeConstraints({
            $0.top.equalTo(contentView.snp.top)
            $0.leading.trailing.equalTo(contentView).inset(0)
            $0.height.equalTo(68)
        })
        
        // top에 profile 박스, 팔로잉/팔로우 버튼 add
        topContainerView.addSubview(profileContainerView)
        topContainerView.addSubview(followingButton)
        
        profileContainerView.snp.makeConstraints({
            $0.top.equalTo(topContainerView.snp.top).offset(16)
            $0.leading.equalTo(topContainerView.snp.leading).offset(20)
            $0.width.equalTo(128)
            $0.height.equalTo(36)
        })
        
        followingButton.snp.makeConstraints({
            $0.top.equalTo(topContainerView.snp.top).offset(19)
            $0.trailing.equalTo(topContainerView.snp.trailing).inset(20)
        })
        
        profileContainerView.addSubviews(nameLabel, categoryLabel, profileImageView)
        
        profileImageView.snp.makeConstraints({
            $0.top.bottom.left.equalToSuperview()
            $0.width.equalTo(profileContainerView.frame.height)
        })
        
        nameLabel.snp.makeConstraints({
            $0.top.equalTo(profileContainerView.snp.top).offset(2)
            $0.leading.equalTo(profileContainerView.snp.leading).offset(44)
        })
        
        categoryLabel.snp.makeConstraints({
            $0.top.equalTo(profileContainerView.snp.top).offset(22)
            $0.leading.equalTo(profileContainerView.snp.leading).offset(44)
        })
        
    }
    
    // MARK: - BODY
    // 피드 이미지, 피드 본문, 하트, 하트수, 댓글, 댓글수
    
    private let bodyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let feedImage: UIImageView = {
        let imageView = UIImageView()
        // 이미지 설정
        //imageView.image = UIImage(systemName: "globe.asia.australia.fill") // 이미지 이름을 적절히 바꾸세요.
        imageView.image = UIImage(named: "cuteBokdol")
        imageView.backgroundColor = .white
        // 이미지의 컨텐트 모드 설정 (옵션)
        imageView.contentMode = .scaleToFill
        // 이미지뷰 크기 설정 (옵션)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.widthAnchor.constraint(equalToConstant: 390).isActive = true
        //imageView.heightAnchor.constraint(equalToConstant: 390).isActive = true
        
        return imageView
    }()
    
    private let feedText: UILabel = {
        let feedText = UILabel()
        feedText.text = "blablablablabla\nblablabla\nblablabla"
        feedText.font = UIFont.pretendard(.regular, size: 14)
        feedText.textColor = UIColor(hex: "200E04")
        feedText.numberOfLines = 3
        feedText.translatesAutoresizingMaskIntoConstraints = false // 오토레이아웃 사용을 위해 false로 설정
        feedText.sizeToFit()
        feedText.setContentHuggingPriority(.required, for: .vertical)
        feedText.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return feedText
    }()
    
    var isHeartFilled: Bool = false
    
    private let heartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = UIColor(hex: "24252E")
        button.isEnabled = true
        
        button.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func heartButtonTapped() {
        isHeartFilled.toggle()
        // 디버깅용
        print("Tapped: heart Filled: \(isHeartFilled)")
        
        if isHeartFilled {
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            heartButton.tintColor = UIColor(hex: "FF4D77")
        } else {
            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
            heartButton.tintColor = UIColor(hex: "24252E")
        }
    }
    
    private let heartRate: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textColor = UIColor(hex: "24252E")
        
        return label
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = UIColor(hex: "24252E")
        
        button.addTarget(self, action: #selector(toDetailFeedView), for: .touchUpInside)
        
        return button
    }()
    
    @objc func toDetailFeedView() {
        let viewController = FeedDetailViewController()
        
        if let navigationController = parentViewController?.navigationController {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    private let messageRate: UILabel = {
        let label = UILabel()
        label.text = "2"
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textColor = UIColor(hex: "24252E")
        
        return label
    }()
    
    private func configureBody() {
        contentView.addSubview(bodyView)
        
        bodyView.snp.makeConstraints({
            $0.top.equalTo(topContainerView.snp.bottom)
            //$0.leading.trailing.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            //$0.width.equalTo(390)
            //$0.height.equalTo(435)
            $0.bottom.equalTo(contentView.snp.bottom).inset(10)
        })
        
        bodyView.addSubviews(feedImage, feedText, heartButton, heartRate, messageButton, messageRate)
        
        feedImage.snp.makeConstraints({
            $0.top.equalTo(bodyView.snp.top)
            $0.horizontalEdges.equalToSuperview()
            //$0.leading.trailing.equalTo(bodyView).inset(0)
            $0.height.equalTo(390)
        })
        feedText.snp.makeConstraints({
            $0.top.equalTo(feedImage.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(bodyView).inset(20)
            //$0.width.equalTo(350)
            //$0.height.equalTo(105)
        })
        heartButton.snp.makeConstraints({
            $0.leading.equalTo(bodyView.snp.leading).offset(20)
            $0.top.equalTo(feedText.snp.bottom).offset(20)
            $0.width.height.equalTo(24)
            $0.bottom.equalTo(bodyView.snp.bottom).inset(16)
        })
        heartRate.snp.makeConstraints({
            $0.leading.equalTo(heartButton.snp.trailing).offset(4)
            $0.top.equalTo(feedText.snp.bottom).offset(21)
            $0.bottom.equalTo(bodyView.snp.bottom).inset(16)
        })
        messageButton.snp.makeConstraints({
            $0.leading.equalTo(heartRate.snp.trailing).offset(12)
            $0.top.equalTo(feedText.snp.bottom).offset(20)
            $0.bottom.equalTo(bodyView.snp.bottom).inset(16)
        })
        messageRate.snp.makeConstraints({
            $0.leading.equalTo(messageButton.snp.trailing).offset(4)
            $0.top.equalTo(feedText.snp.bottom).offset(21)
            $0.bottom.equalTo(bodyView.snp.bottom).inset(16)
        })
    }
    
    func configure(nameText: String, categoryText: String, profileImageName: UIImage, feedImageName: UIImage, feedText: String) {
        self.nameLabel.text = nameText
        self.categoryLabel.text = categoryText
        self.profileImageView.image = profileImageName
        self.feedImage.image = feedImageName
        self.feedText.text = feedText
    }
    
    /*
     let imageView = UIImageView(image: UIImage(named: "yourImageName"))
     imageView.layer.cornerRadius = imageView.frame.size.width / 2
     imageView.clipsToBounds = true
     */
}
