//
//  FeedDetailViewController.swift
//  MOGAK
//
//  Created by 이재혁 on 2023/08/12.
//

import UIKit
import SnapKit
import Then

class FeedDetailViewController: UIViewController {
    // scrollview 선언
    var scrollView: UIScrollView = UIScrollView().then {
        $0.backgroundColor = .white
    }
    
    // UIScrollView 안에 들어갈 객체들을 담은 View 선언
    var contentView: UIView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // MARK: - 상단 통합 컨테이너
    lazy var topContainerView: UIView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - PROFILE HEADER
    // 프로필 이미지, 이름, 카테고리 컨테이너
    private let profileContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // 이름
    private let nameLabel : UILabel = {
          let label = UILabel()
          label.text = "이재혁"
          label.font = UIFont.pretendard(.semiBold, size: 14)
          label.textColor = UIColor(hex: "24252E")
          return label
      }()

      // 카테고리
      private let categoryLabel : UILabel = {
          let label = UILabel()
          label.text = "서비스기획자/PM"
        label.font = UIFont.pretendard(.regular, size: 12)
        label.textColor = UIColor(hex: "6E707B")
        return label
    }()
    
    // 프로필사진
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        // 이미지 설정
        imageView.image = UIImage(systemName: "person.circle.fill")
        // 이미지의 컨텐트 모드 설정 (옵션)
        imageView.contentMode = .scaleAspectFit
        // 이미지뷰 크기 설정 (옵션)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .systemBlue
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // vertical ellipsis button
    private let editButton: UIButton = {
        let button = UIButton()
        let ellipsis = UIImage(systemName: "ellipsis")
        let verticalImage = ellipsis?.rotate(radians: .pi/2) // 90도 회전
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        
        return button
    }()
    
    // 팔로우팔로잉 버튼
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
    
    // MARK: - Configure scrollview
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        })
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.centerX.top.bottom.equalToSuperview()
        })
    }
    
    // MARK: - 상단 통합 컨테이너
    private func configureTopContainer() {
        contentView.addSubview(topContainerView)
        topContainerView.snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.top.equalToSuperview().offset(40) // 나중에 offset 바꾸기
            $0.height.equalTo(68)
        })
        
        topContainerView.addSubviews(profileContainerView, editButton, followingButton)
        
        profileContainerView.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(128)
            $0.height.equalTo(36)
        })
        
        editButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        })
        
        followingButton.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(editButton.snp.leading).offset(-12)
        })
    }
    
    // MARK: - 프로필 컨테이너 <- addsubviews
    private func configureProfileElements() {
        profileContainerView.addSubviews(nameLabel, profileImageView, categoryLabel)
        
        profileImageView.snp.makeConstraints({
            $0.top.bottom.left.equalToSuperview()
            $0.width.equalTo(profileContainerView.frame.height)
        })
        
        nameLabel.snp.makeConstraints({
            $0.bottom.equalTo(profileContainerView.snp.centerY).offset(2)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
        })
        
        categoryLabel.snp.makeConstraints({
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(profileContainerView.snp.centerY).offset(-2)
        })
    }
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        configureScrollView()
        configureTopContainer()
        configureProfileElements()
    }
}
