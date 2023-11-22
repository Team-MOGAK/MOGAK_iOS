//
//  FriendDetailPageViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/08/11.
//

import UIKit
import SnapKit

class FriendDetailPageViewController: UIViewController {
    
    private var progressCount = 3
    private var failCount = 3
    private var successCount = 5
    
    private lazy var profileImage : UIImageView = {
        let view = UIImageView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.image = UIImage(named: "default")
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
    
    private lazy var mogakerLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAKER 2"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = UIColor(hex: "FFFFFF")
        let gesture = UITapGestureRecognizer(target: self, action: #selector(goToFriendPage))
        label.addGestureRecognizer(gesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let mogakeeLabel : UILabel = {
        let label = UILabel()
        label.text = "MOGAKEE 5"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = UIColor(hex: "FFFFFF")
        return label
    }()
    
    private let followLineView : UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "FFFFFF").cgColor
        return view
    }()
    
    private lazy var followButton = UIButton().then {
        $0.setTitle("팔로잉", for: .normal)
        $0.setTitleColor(UIColor(hex: "475FFD"), for: .normal)
        $0.backgroundColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.6)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 14)
        $0.layer.cornerRadius = 10
        $0.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }

    private let achievementLabel = UILabel().then {
        $0.text = "성취율"
        $0.textColor = UIColor(hex: "ffffff")
        $0.font = UIFont.pretendard(.medium, size: 12)
    }
    
    private let circle1 = UIView().then {
        $0.backgroundColor = UIColor(hex: "ffffff")
    }
    
    private let circle2 = UIView().then {
        $0.backgroundColor = UIColor(hex: "ffffff")
    }
    
    private let circle3 = UIView().then {
        $0.backgroundColor = UIColor(hex: "ffffff")
    }
    
    private let circle4 = UIView().then {
        $0.backgroundColor = UIColor(hex: "ffffff")
    }
    
    private let circle5 = UIView().then {
        $0.backgroundColor = UIColor(hex: "ffffff").withAlphaComponent(0.6)
    }
    
    private let achievementPercent = UILabel().then {
        $0.text = "80%"
        $0.textColor = UIColor(hex: "ffffff")
        $0.font = UIFont.pretendard(.bold, size: 22)
    }
    
    private let togetherLabel = UILabel().then {
        $0.text = "모각과 함께한지 61일!"
        $0.textColor = UIColor(hex: "ffffff").withAlphaComponent(0.6)
        $0.font = UIFont.pretendard(.regular, size: 12)
    }
    
    private lazy var containerView : UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(hex: "ffffff")
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    private lazy var listTableView : UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hex: "F1F3FA")
        return tableView
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        
        segment.selectedSegmentTintColor = .clear
        // 배경 색 제거
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        // Segment 구분 라인 제거
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        let progressTitle = progressCount == 0 ? "진행중" : "진행중 \(progressCount)"
        let failTitle = failCount == 0 ? "실패" : "실패 \(failCount)"
        let successTitle = successCount == 0 ? "성공" : "성공 \(successCount)"
        
        segment.insertSegment(withTitle: progressTitle, at: 0, animated: true)
        segment.insertSegment(withTitle: failTitle, at: 1, animated: true)
        segment.insertSegment(withTitle: successTitle, at: 2, animated: true)
        
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
        
        view.backgroundColor = UIColor(hex: "475FFD")
        self.configureNavBar()
        self.configureTop()
        self.configureSegment()
        self.configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        configureNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        
        [circle1, circle2, circle3, circle4, circle5].forEach({$0.layer.cornerRadius = 18})
    }
    
    
    private func configureNavBar() {
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: "ffffff"), .font: UIFont.pretendard(.semiBold, size: 18)
            ]
        self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "verticalEllipsis"), style: .plain, target: self, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "ffffff")
        self.title = "친구 프로필"
    }
    
    private func configureTop() {
        [profileImage, profileName, profileJob, mogakerLabel, mogakeeLabel, followLineView, followButton, achievementLabel, circle1, circle2, circle3, circle4, circle5, achievementPercent, togetherLabel].forEach({view.addSubview($0)})
        
        profileImage.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(21)
            $0.leading.equalToSuperview().offset(30)
            $0.width.height.equalTo(44)
        })
        
        profileName.snp.makeConstraints({
            $0.top.equalTo(profileImage.snp.top)
            $0.leading.equalTo(profileImage.snp.trailing).offset(11)
        })
        
        profileJob.snp.makeConstraints({
            $0.top.equalTo(profileName.snp.bottom).offset(8)
            $0.leading.equalTo(profileImage.snp.trailing).offset(11)
        })
        
        mogakerLabel.snp.makeConstraints({
            $0.top.equalTo(profileJob.snp.bottom).offset(12)
            $0.leading.equalTo(self.profileJob.snp.leading)
        })
        
        followLineView.snp.makeConstraints({
            $0.centerY.equalTo(mogakerLabel.snp.centerY)
            $0.leading.equalTo(mogakerLabel.snp.trailing).offset(16)
            $0.height.equalTo(12)
            $0.width.equalTo(1)
        })
        
        mogakeeLabel.snp.makeConstraints({
            $0.centerY.equalTo(self.mogakerLabel.snp.centerY)
            $0.leading.equalTo(followLineView.snp.trailing).offset(16)
        })
        
        followButton.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(57)
            $0.height.equalTo(30)
        })

        achievementLabel.snp.makeConstraints({
            $0.top.equalTo(self.mogakerLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(85)
        })
        
        circle1.snp.makeConstraints({
            $0.top.equalTo(self.achievementLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(86)
            $0.width.height.equalTo(36)
        })
        
        circle2.snp.makeConstraints({
            $0.centerY.equalTo(self.circle1.snp.centerY)
            $0.leading.equalTo(self.circle1.snp.trailing)
            $0.width.height.equalTo(36)
        })
        
        circle3.snp.makeConstraints({
            $0.centerY.equalTo(self.circle2.snp.centerY)
            $0.leading.equalTo(self.circle2.snp.trailing)
            $0.width.height.equalTo(36)
        })
        
        circle4.snp.makeConstraints({
            $0.centerY.equalTo(self.circle3.snp.centerY)
            $0.leading.equalTo(self.circle3.snp.trailing)
            $0.width.height.equalTo(36)
        })
        
        circle5.snp.makeConstraints({
            $0.centerY.equalTo(self.circle4.snp.centerY)
            $0.leading.equalTo(self.circle4.snp.trailing)
            $0.width.height.equalTo(36)
        })
        
        achievementPercent.snp.makeConstraints({
            $0.centerY.equalTo(self.circle5.snp.centerY)
            $0.leading.equalTo(self.circle5.snp.trailing).offset(16)
        })
        
        togetherLabel.snp.makeConstraints({
            $0.top.equalTo(self.circle1.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(85)
        })
    }
    
    private func configureSegment() {
        view.addSubview(containerView)
        containerView.addSubview(segmentControl)
        containerView.addSubview(underLineView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: togetherLabel.bottomAnchor, constant: 32),
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
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.register(ListTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(listTableView)
        
        listTableView.snp.makeConstraints({
            $0.top.equalTo(self.containerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
        })
        
    }

    
    @objc private func goToFriendPage() {
        
    }
    
    @objc private func followButtonTapped() {
        if followButton.titleLabel?.text == "팔로잉" {
            self.followButton.setTitle("팔로우", for: .normal)
            self.followButton.backgroundColor = UIColor(hex: "ffffff")
            self.followButton.setImage(UIImage(systemName: "plus"), for: .normal)
            self.followButton.semanticContentAttribute = .forceRightToLeft
            self.followButton.tintColor = UIColor(hex: "475FFD")
            
            followButton.snp.updateConstraints({
                $0.width.equalTo(71)
            })
            
        } else if followButton.titleLabel?.text == "팔로우" {
            self.followButton.setTitle("팔로잉", for: .normal)
            self.followButton.backgroundColor = UIColor(hex: "ffffff").withAlphaComponent(0.6)
            self.followButton.setImage(nil, for: .normal)
            
            followButton.snp.updateConstraints({
                $0.width.equalTo(57)
            })
        }
    }
    
    @objc private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(segmentControl.selectedSegmentIndex)
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.leadingDistance.constant = leadingDistance
            self?.view.layoutIfNeeded()
        })
        self.listTableView.reloadData()
    }
    
}

extension FriendDetailPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            return progressCount == 0 ? 1 : progressCount
        case 1:
            return failCount == 0 ? 1 : failCount
        case 2:
            return successCount == 0 ? 1 : successCount
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ListTableViewCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            cell.configure(backColor: UIColor(hex: "E8EBFE"), titleText: "progress", statusText: "진행중", categoryText: "자격증", statusTextColor: UIColor(hex: "475FFD"))
        case 1:
            cell.configure(backColor: UIColor(hex: "FFDEDE"), titleText: "fail", statusText: "실패", categoryText: "공모전", statusTextColor: UIColor(hex: "FF2323"))
        case 2:
            cell.configure(backColor: UIColor(hex: "E7F9F3"), titleText: "success", statusText: "성공", categoryText: "자격증", statusTextColor: UIColor(hex: "009967"))
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell else {
            return
        }
        
        let detailVC = JogakDetailViewController()
        
        if let status = cell.smallGoalLabel.text,
           let category = cell.episodeLabel.text,
           let title = cell.titleLabel.text,
           let color = cell.smallGoalView.backgroundColor,
           let textColor = cell.smallGoalLabel.textColor
        {
            detailVC.configureData(color: color, status: status, category: category, title: title, textColor: textColor)
        }
        detailVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(detailVC, animated: true)
        //        self.present(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
