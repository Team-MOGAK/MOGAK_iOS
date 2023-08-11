//
//  FriendsListViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/08.
//

import UIKit
import SnapKit

class FriendsListViewController: UIViewController {
    
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
        
        segment.insertSegment(withTitle: "팔로잉", at: 0, animated: true)
        segment.insertSegment(withTitle: "팔로워", at: 1, animated: true)
        
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
    
    private let tableView = UITableView().then {
        $0.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.configureNavBar()
        self.configureSegment()
        self.configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        configureNavBar()
    }
    
    private func configureNavBar() {
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: "24252E"), .font: UIFont.pretendard(.semiBold, size: 18)
            ]
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
        self.title = "내 친구"
        self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
    }
    
    
    private func configureSegment() {
        view.addSubview(containerView)
        containerView.addSubview(segmentControl)
        containerView.addSubview(underLineView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 46),
            
            segmentControl.topAnchor.constraint(equalTo: containerView.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentControl.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            segmentControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            underLineView.bottomAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            underLineView.heightAnchor.constraint(equalToConstant: 2),
            leadingDistance,
            underLineView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments))
        ])
        
    }

    private func configureTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FollowingCell.self, forCellReuseIdentifier: "FollowingCell")
        tableView.backgroundColor = .white
        
        tableView.snp.makeConstraints({
            $0.top.equalTo(self.containerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        })
    }

    @objc private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(segmentControl.selectedSegmentIndex)
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.leadingDistance.constant = leadingDistance
            self?.view.layoutIfNeeded()
        })
        self.tableView.reloadData()
    }

}

extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell") as? FollowingCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        cell.followingDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

extension FriendsListViewController: FollowingDelegate {
    func profileImageTapped() {
        print("클릭")
        let friendVC = FriendDetailPageViewController()
        friendVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(friendVC, animated: true)
    }
}

