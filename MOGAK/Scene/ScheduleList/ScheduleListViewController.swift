//
//  NetworkingViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import SnapKit

class ScheduleListViewController: UIViewController {
    
    private var progressCount = 3
    private var failCount = 3
    private var successCount = 5
    
    // MARK: - Top
    private let topView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let settingButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "person"), for: .normal)
        button.tintColor = UIColor(hex: "ffffff")
        return button
    }()
    
    private lazy var profileImage : UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = view.frame.height / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        view.image = UIImage(named: "default")
        let gesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        view.addGestureRecognizer(gesture)
        view.isUserInteractionEnabled = true
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
        label.text = "MENTOR 2"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = UIColor(hex: "FFFFFF")
        let gesture = UITapGestureRecognizer(target: self, action: #selector(goToFriendPage))
        label.addGestureRecognizer(gesture)
        label.isUserInteractionEnabled = true
        label.asFontColor(targetString: "MENTOR", font: UIFont.pretendard(.medium, size: 16), color: UIColor(hex: "ffffff").withAlphaComponent(0.9))
        return label
    }()
    
    private let mogakeeLabel : UILabel = {
        let label = UILabel()
        label.text = "MOTO 5"
        label.font = UIFont.pretendard(.medium, size: 16)
        label.textColor = UIColor(hex: "FFFFFF")
        label.asFontColor(targetString: "MOTO", font: UIFont.pretendard(.medium, size: 16), color: UIColor(hex: "ffffff").withAlphaComponent(0.9))
        return label
    }()
    
    private let followLineView : UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "FFFFFF").cgColor
        return view
    }()
    
    // MARK: - segment
    private lazy var containerView : UIView = {
        let container = UIView()
        container.backgroundColor = .white
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
    
    // MARK: - tableView
    private lazy var listTableView : UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hex: "F1F3FA")
        return tableView
    }()
    
    private lazy var floatingButton : UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(hex: "475FFD")
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .regular))
        button.configuration = config
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "F1F3FA")
        self.configureTop()
        self.configureSegment()
        self.configureTableView()
        self.configureButton()
        
    }
    
    override func viewWillLayoutSubviews() {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 70, y: view.frame.size.height - 150, width: 48, height: 48)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    private func configureTop() {
        self.view.addSubview(topView)
        self.topView.addSubviews(settingButton, profileImage, profileName, profileJob, mogakerLabel, mogakeeLabel, followLineView)
        
        topView.backgroundColor = UIColor(hex: "475FFD")
        
        profileImage.layer.cornerRadius = 22
        
        topView.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(156)
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
        
        settingButton.snp.makeConstraints({
            //            $0.top.equalTo(topView.snp.top).offset(63)
            $0.centerY.equalTo(self.profileName.snp.centerY)
            $0.trailing.equalTo(topView.snp.trailing).offset(-22.35)
            $0.width.height.equalTo(24)
        })
        
        
        mogakerLabel.snp.makeConstraints({
            $0.top.equalTo(profileJob.snp.bottom).offset(12)
            $0.leading.equalTo(topView.snp.leading).offset(85)
        })
        
        mogakeeLabel.snp.makeConstraints({
            $0.top.equalTo(profileJob.snp.bottom).offset(12)
            $0.trailing.equalTo(topView.snp.trailing).offset(-94)
        })
        
        followLineView.snp.makeConstraints({
            $0.centerY.equalTo(mogakerLabel.snp.centerY)
            $0.leading.equalTo(mogakerLabel.snp.trailing).offset(16)
            $0.trailing.equalTo(mogakeeLabel.snp.leading).offset(-16)
            $0.height.equalTo(12)
            $0.width.equalTo(1)
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
        
    }
    
    private func configureButton() {
        self.view.addSubview(floatingButton)
        
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
    
    @objc private func segmentSelected() {
        switch(segmentControl.selectedSegmentIndex) {
        case 0:
            listTableView.reloadData()
        case 1:
            listTableView.reloadData()
        case 2:
            listTableView.reloadData()
        default:
            break
        }
    }
    
    @objc private func floatingButtonTapped() {
        let mogakVC = MogakInitViewController()
        //        let testVC = TestViewController()
        self.navigationController?.pushViewController(mogakVC, animated: true)
    }
    
    
    @objc private func profileImageTapped() {
        print("클릭")
        let settingVC = MyPageViewController()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc private func goToFriendPage() {
        let pageVC = FriendsListViewController()
        self.navigationController?.pushViewController(pageVC, animated: true)
    }
    
}

extension ScheduleListViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        if let status = cell.statusLabel.text,
           let category = cell.categoryLabel.text,
           let title = cell.titleLabel.text,
           let color = cell.statusView.backgroundColor,
           let textColor = cell.statusLabel.textColor
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

