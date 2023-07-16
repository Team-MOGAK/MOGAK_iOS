//
//  NetworkingViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import SnapKit

class ScheduleListViewController: UIViewController {
    
    // MARK: - Top
    private let topView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let settingButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "setting"), for: .normal)
        return button
    }()
    
    private let profileImage : UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = view.frame.height/2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.image = UIImage(named: "setting")
        return view
    }()
    
    private let profileName : UILabel = {
        let label = UILabel()
        label.text = "김동동"
        label.font = UIFont.pretendard(.bold, size: 22)
        label.textColor = UIColor(hex: "FFFFFF")
        return label
    }()
    
    private let profileJob : UILabel = {
        let label = UILabel()
        label.text = "서비스기획자/PM"
        label.font = UIFont.pretendard(.medium, size: 12)
        label.textColor = UIColor(hex: "FFFFFF")
        return label
    }()
    
    // MARK: - segment
    private lazy var containerView : UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.selectedSegmentTintColor = .clear
        // 배경 색 제거
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        // Segment 구분 라인 제거
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        segment.insertSegment(withTitle: "진행중", at: 0, animated: true)
        segment.insertSegment(withTitle: "실패", at: 1, animated: true)
        segment.insertSegment(withTitle: "성공", at: 2, animated: true)
        
        segment.selectedSegmentIndex = 0
        
        // 선택 되어 있지 않을때 폰트 및 폰트컬러
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(hex: "BFC3D4"),
            NSAttributedString.Key.font: UIFont.pretendard(.medium, size: 16)
        ], for: .normal)
        
        // 선택 되었을때 폰트 및 폰트컬러
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(hex: "24252E"),
            NSAttributedString.Key.font: UIFont.pretendard(.medium, size: 16)
        ], for: .selected)
        
        segment.addTarget(self, action: #selector(changeSegmentedControlLinePosition), for: .valueChanged)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private lazy var underLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "475FFD")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 움직일 underLineView의 leadingAnchor 따로 작성
    private lazy var leadingDistance: NSLayoutConstraint = {
        return underLineView.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "F1F3FA")
        
        self.configureTop()
        self.configureSegment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(segmentControl.selectedSegmentIndex)
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.leadingDistance.constant = leadingDistance
            self?.view.layoutIfNeeded()
        })
    }
    
    private func configureTop() {
        self.view.addSubview(topView)
        self.topView.addSubviews(settingButton, profileImage, profileName, profileJob)
        
        topView.backgroundColor = UIColor(hex: "475FFD")
        
        topView.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(156)
        })
        
        settingButton.snp.makeConstraints({
            $0.top.equalTo(topView.snp.top).offset(63)
            $0.trailing.equalTo(topView.snp.trailing).offset(-22.35)
            $0.width.equalTo(19.65)
            $0.height.equalTo(20)
        })
        
        profileImage.snp.makeConstraints({
            $0.top.equalTo(topView.snp.top).offset(61)
            $0.leading.equalTo(topView.snp.leading).offset(30)
            $0.width.height.equalTo(44)
        })
        
        profileName.snp.makeConstraints({
            $0.top.equalTo(topView.snp.top).offset(62)
            $0.leading.equalTo(profileImage.snp.trailing).offset(11)
        })
        
        profileJob.snp.makeConstraints({
            $0.top.equalTo(profileName.snp.bottom).offset(8)
            $0.leading.equalTo(profileImage.snp.trailing).offset(11)
        })
    }
    
    private func configureSegment() {
        view.addSubview(containerView)
        containerView.addSubview(segmentControl)
        containerView.addSubview(underLineView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 46),
            
            segmentControl.topAnchor.constraint(equalTo: containerView.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentControl.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            segmentControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            underLineView.bottomAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            underLineView.heightAnchor.constraint(equalToConstant: 2),
            leadingDistance,
            underLineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments))
        ])    }
    
}
