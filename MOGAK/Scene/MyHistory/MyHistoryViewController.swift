//
//  MyHistoryViewController.swift
//  MOGAK
//
//  Created by 이재혁 on 10/11/23.
//

import UIKit
import SnapKit

class MyHistoryViewController: UIViewController {
    
    //MARK: - 임시 데이터들
    var modalArtNameArr: [String] = ["김라영의 모다라트", "운동하기", "내 모다라트3"]
    var modalartName: String = "" ///현재 보여지는 모다라트 타이틀
    var modalartList: [ModalartList] = [] ///모든 모다라트 리스트
    var nowShowModalArtNum: Int = 0 ///현재 보여지는 모다라트의 번호
    var nowShowModalArtIndex: Int = 0
    var mogakData: [MogakCategory] = []
    
    var modalArtMainCellBgColor: String = "" ///현재 보여지는 모다라트 메인 셀의 배경색
    ///
    
    let modalartNetwork = ModalartNetwork()
    
    var selectedSmallModalartIndexPath: IndexPath?
    var selectedMogakCategoryIndexPath: IndexPath?
    private var tableViewData: [[String]] = []
    private var mogakCategoryViewData: [String] = []
    var MemoirListTableViewData: [MemoirContent] = []
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        self.tabBarController?.tabBar.isHidden = false
    //        print("viewWillAppear")
    //    }
    //
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        self.tabBarController?.tabBar.isHidden = false
    //        self.navigationController?.navigationBar.isHidden = true
    //        print("viewDidAppear")
    //    }
    //
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        self.tabBarController?.tabBar.isHidden = true
    //    }
    
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
    
    // MARK: - MODALART select pulldown
    private let selectModalart: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.pretendard(.semiBold, size: 20)
        button.tintColor = UIColor(hex: "FFFFFF")
        
        button.setTitle("", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(showModalartListTapped), for: .touchUpInside)
        
        let intervalSpacing = 6.0
        let halfIntervalSpacing = intervalSpacing / 2
        button.contentEdgeInsets = .init(top: 0, left: halfIntervalSpacing, bottom: 0, right: halfIntervalSpacing)
        button.imageEdgeInsets = .init(top: 0, left: halfIntervalSpacing, bottom: 0, right: -halfIntervalSpacing)
        button.titleEdgeInsets = .init(top: 0, left: -halfIntervalSpacing, bottom: 0, right: halfIntervalSpacing)
        
        button.semanticContentAttribute = .forceRightToLeft
        
        return button
    }()
    
    //MARK: - 모다라트 전체 리스트 가져오기
    func getModalartAllList() {
        modalartNetwork.getModalartList { result in
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error:\(error.localizedDescription)")
            case .success(let list):
                guard let modalartList = list else { return }
                self.modalartList = modalartList
                print(#fileID, #function, #line, "- modalartList checking:\(self.modalartList)")
                
                if modalartList.isEmpty {
                    self.modalartName = "내 모다라트"
                    self.modalArtMainCellBgColor = "BFC3D4"
                }
                else {
                    guard let firstData = modalartList.first else { return }
                    self.nowShowModalArtNum = firstData.id
                    self.nowShowModalArtIndex = 0
                    self.getModalartDetailInfo(id: self.nowShowModalArtNum)
                }
            }
        }
        getModalartDetailInfo(id: nowShowModalArtNum)
    }
    
    //MARK: - 현재 생성된 모다라트 리스트 보여줌
    @objc private func showModalartListTapped() {
        print(#fileID, #function, #line, "- 모다라트 추가 버튼 탭")
        let showModalartListModalVC = ShowModalArtListModal()
        showModalartListModalVC.modalArtNameList = modalartList
        
        ///모다라트 리스트를 보여주는 모달에서 원하는 리스트를 선택했을 경우
        showModalartListModalVC.changeToSelectedModalart = { modalArtData, listIndex in
            let num = modalArtData.id
            let title = modalArtData.title
            
            ///모다라트 타이틀이 설정됬는지 체크
            let hasModalArtNameChecking: Bool = title.prefix(6) != "내 모다라트"
            ///모다라트 추가 리스트를 클릭했는지 체크
            let modalArtNameIsAddModalart: Bool = title == "모다라트 추가"
            
            self.nowShowModalArtNum = num
            self.nowShowModalArtIndex = listIndex
            ///모다라트 타이틀 설정됨
            if hasModalArtNameChecking && !modalArtNameIsAddModalart {
                self.getModalartDetailInfo(id: num)
            }
            ///모다라트 추가 클릭
//            else if hasModalArtNameChecking && modalArtNameIsAddModalart {
//                self.createModalart()
//            }
            ///모다라트 타이틀 설정 안됨
            else {
                self.mogakData = []
                //self.modalArtNameLabel.text = title
                self.modalartName = title
                //self.modalArtCollectionView.reloadData()
            }
        }
        
        showModalartListModalVC.modalPresentationStyle = .overFullScreen
        showModalartListModalVC.modalTransitionStyle = .crossDissolve
        self.present(showModalartListModalVC, animated: false)
    }

    private var groupedMogakData: [String: [MogakCategory]] = [:]
    
    //MARK: - 단일 모다라트 디테일 정보 가져오기
    func getModalartDetailInfo(id: Int) {
        modalartNetwork.getDetailModalartInfo(modalartId: id) { result in
            switch result {
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            case .success(let modalInfo):
                guard let modalInfo = modalInfo else { return }

                self.nowShowModalArtNum = modalInfo.id
                self.modalartName = modalInfo.title
                self.selectModalart.setTitle(modalInfo.title, for: .normal)
                self.modalArtMainCellBgColor = modalInfo.color
                self.mogakData = modalInfo.mogakCategory ?? []
                //print(self.mogakData[0].bigCategory?.name)
                //self.modalArtCollectionView.reloadData()
                self.smallModalartList = []
                for i in self.mogakData {
                    self.smallModalartList.append((i.bigCategory.name)) // bigCategory로 grouping 하는거 추가하기
                }
                self.smallModalartList = self.smallModalartList.uniqued()
                self.segmentFirstLoaded = false
                self.segmentCollectionView.reloadData()
                
                // test
                self.groupedMogakData = self.groupMogaksByCategory(mogakData: self.mogakData)
                print("-----------------grouping 테스트------------------")
                print(self.groupedMogakData)
                print("-----------------grouping 테스트------------------")
            }
        }
    }
    
    func groupMogaksByCategory(mogakData: [MogakCategory]) -> [String: [MogakCategory]] {
        let groupedCategories = Dictionary(grouping: mogakData) { (mogakCategory) -> String in
            return mogakCategory.bigCategory.name ?? "Unknown"
        }
        
        return groupedCategories
    }
    
    func titlesForSelectedCategory(selectedCategory: String, groupedCategories: [String: [MogakCategory]]) -> [String] {
        guard let selectedCategoryItems = groupedCategories[selectedCategory] else {
            return []
        }
        
        let titles = selectedCategoryItems.map { $0.title ?? "" }
        return titles
    }
    
    // MARK: - scrollview for segment
    private let segmentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.contentSize = CGSize(width: .zero, height: 46)
        
        return scrollView
    }()
    
    // MARK: - segment
    private lazy var containerView : UIView = {
        let container = UIView()
        //container.backgroundColor = .white
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
        
//        let progressTitle = progressCount == 0 ? "진행중" : "진행중 \(progressCount)"
//        let failTitle = failCount == 0 ? "실패" : "실패 \(failCount)"
//        let successTitle = successCount == 0 ? "성공" : "성공 \(successCount)"
        let progressTitle = "직무"
        let failTitle = "자격증"
        let successTitle = "시험"
        let healthTitle = "건강"
        let categoryTitle = "카테고리"
        let inprogressTitle = "진행중"
        
        segment.insertSegment(withTitle: progressTitle, at: 0, animated: true)
        segment.insertSegment(withTitle: failTitle, at: 1, animated: true)
        segment.insertSegment(withTitle: successTitle, at: 2, animated: true)
        segment.insertSegment(withTitle: healthTitle, at: 3, animated: true)
        segment.insertSegment(withTitle: categoryTitle, at: 4, animated: true)
        segment.insertSegment(withTitle: inprogressTitle, at: 5, animated: true)
        segment.insertSegment(withTitle: inprogressTitle, at: 6, animated: true)
        segment.insertSegment(withTitle: inprogressTitle, at: 7, animated: true)
        
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
    
    // MARK: - Segment 대신할 collectionView
    private lazy var segmentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        //layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.tag = 1
        return collectionView
    }()
    
    private lazy var mogakCategoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.tag = 2
        return collectionView
    }()
    
    private var smallModalartList: [String] = [
        
    ]
    
    private var mogakTitleList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "F1F3FA")
        //self.configureTop()
        self.configureSelectModalart()
        //self.configureSegment()
        self.configureSegmentCollectionView()
        self.configureMogakCategoryCollectionView()
        self.configureTableView()
        self.configureButton()
        getModalartAllList()
        
//        let defaultSelectedIndexPath = IndexPath(item: 0, section: 0)
//        segmentCollectionView.selectItem(at: defaultSelectedIndexPath, animated: false, scrollPosition: .init())
//        collectionView(segmentCollectionView, didSelectItemAt: defaultSelectedIndexPath)
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
        getModalartAllList()
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
    
    // MARK: - configure Modalart Selection
    private func configureSelectModalart() {
        view.addSubview(selectModalart)
        
        selectModalart.snp.makeConstraints({
            $0.leading.equalToSuperview().inset(20)
            //$0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.top.equalTo(view.snp.top).offset(80)
        })
    }
    
    // MARK: - configure Segment
    private func configureSegment() {
        //view.addSubview(containerView)
        //segmentScrollView.addSubview(containerView)
        view.addSubview(segmentScrollView)
//        containerView.addSubview(segmentControl)
//        containerView.addSubview(underLineView)
        segmentScrollView.addSubview(segmentControl)
        
        segmentScrollView.addSubview(underLineView)
        
        // 11/7 지피티
        segmentScrollView.contentSize = CGSize(width: segmentControl.frame.width, height: 46)
        
//        var scrollViewWidth: Float = 0.0
//        let items = ["직무", "자격증", "시험", "건강", "카테고리", "진행중", "진행중", "진행중"]
//
//        for (index, element) in items.enumerated() {
//            let size = element.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
//            segmentControl.setWidth(size.width, forSegmentAt: index)
//            scrollViewWidth = scrollViewWidth + Float(size.width)
//        }
//        segmentScrollView.contentSize = CGSize(width: Int(scrollViewWidth), height: 46)
        
        
        
        NSLayoutConstraint.activate([
            segmentScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            //segmentScrollView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            segmentScrollView.topAnchor.constraint(equalTo: selectModalart.bottomAnchor, constant: 12),
            segmentScrollView.heightAnchor.constraint(equalToConstant: 46),
            
            //segmentScrollView.widthAnchor.constraint(equalToConstant: 600)
        ])
        
//        containerView.snp.makeConstraints {
//            $0.edges.equalTo(segmentScrollView.contentLayoutGuide)
//            $0.height.equalTo(segmentScrollView.frameLayoutGuide)
//            //$0.width.equalTo(600)
//        }
        
        NSLayoutConstraint.activate([
//            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            containerView.topAnchor.constraint(equalTo: topView.bottomAnchor),
//            containerView.heightAnchor.constraint(equalToConstant: 46),
            
//            containerView.leadingAnchor.constraint(equalTo: segmentScrollView.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: segmentScrollView.trailingAnchor),
//            containerView.topAnchor.constraint(equalTo: segmentScrollView.topAnchor),
//            containerView.bottomAnchor.constraint(equalTo: segmentScrollView.bottomAnchor),
//            containerView.heightAnchor.constraint(equalToConstant: 46),
            
           // containerView.widthAnchor.constraint(equalToConstant: 600),
            
//            segmentControl.topAnchor.constraint(equalTo: containerView.topAnchor),
//            segmentControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            segmentControl.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            segmentControl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//
//            segmentControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            segmentControl.topAnchor.constraint(equalTo: segmentScrollView.topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: segmentScrollView.leadingAnchor),
//            segmentControl.centerYAnchor.constraint(equalTo: segmentScrollView.centerYAnchor),
//            segmentControl.centerXAnchor.constraint(equalTo: segmentScrollView.centerXAnchor),
            
            segmentControl.trailingAnchor.constraint(equalTo: segmentScrollView.trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),
            
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
            //$0.top.equalTo(self.containerView.snp.bottom)
            //$0.top.equalTo(self.segmentScrollView.snp.bottom)
            //$0.top.equalTo(self.segmentCollectionView.snp.bottom)
            $0.top.equalTo(self.mogakCategoryCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
        
    }
    
    private func configureSegmentCollectionView() {
        segmentCollectionView.delegate = self
        segmentCollectionView.dataSource = self
        
        segmentCollectionView.register(SegmentCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(segmentCollectionView)
        
        segmentCollectionView.snp.makeConstraints({
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(selectModalart.snp.bottom).offset(12)
            //$0.top.equalTo(segmentScrollView.snp.bottom).offset(12)
            $0.height.equalTo(46)
        })
    }
    
    private func configureMogakCategoryCollectionView() {
        mogakCategoryCollectionView.delegate = self
        mogakCategoryCollectionView.dataSource = self
        
        mogakCategoryCollectionView.register(MogakCategoryDetailCollectionViewCell.self, forCellWithReuseIdentifier: "mogakCategoryCell")
        
        self.view.addSubview(mogakCategoryCollectionView)
        
        mogakCategoryCollectionView.snp.makeConstraints({
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(segmentCollectionView.snp.bottom).offset(16)
            $0.height.equalTo(43)
        })
    }
    
    private func configureButton() {
        self.view.addSubview(floatingButton)
        
        floatingButton.snp.makeConstraints({
            $0.top.equalTo(view.snp.top).offset(60)
            $0.leading.equalTo(selectModalart.snp.trailing).offset(16)
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
        //let mogakVC = JogakInitViewController()
        //let mogakVC = MogakEditViewController()
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
    
    var segmentFirstLoaded: Bool = false
    var mogakCategoryFirstLoaded: Bool = false
}

extension MyHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return smallModalartList.count
        } else if collectionView.tag == 2 {
            return mogakTitleList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SegmentCollectionViewCell else {
                return UICollectionViewCell()
            }
            // 카테고리 디폴트 셀 설정(첫번째로)
            if indexPath.row == 0 && segmentFirstLoaded == false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                cell.isSelected = true
                cell.textLabel.textColor = UIColor(hex: "24252E")
                cell.underLineView.fadeIn()
                
                self.mogakTitleList = titlesForSelectedCategory(selectedCategory: cell.textLabel.text!, groupedCategories: groupedMogakData)
                self.mogakCategoryCollectionView.reloadData()
                
                configureTableViewData(forSelectedItem: smallModalartList[indexPath.item])
                // 선택된 셀의 인덱스를 저장
                selectedSmallModalartIndexPath = indexPath
                listTableView.reloadData()
                segmentFirstLoaded.toggle()
            }

    //        cell.isSelectedCell = indexPath == defaultSegmentIndexPath
            cell.textLabel.text = smallModalartList[indexPath.item]
            
            return cell
        }
        else if collectionView.tag == 2 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mogakCategoryCell", for: indexPath) as? MogakCategoryDetailCollectionViewCell else {
                return UICollectionViewCell()
            }
            // 첫번째로 디폴트 셀 설정
            if indexPath.row == 0 && mogakCategoryFirstLoaded == false {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
                cell.isSelected = true
                cell.mogakNameLabel.textColor = UIColor(hex: "F1F3FA")
                cell.mogakNameView.backgroundColor = UIColor(hex: "24252E")
                selectedMogakCategoryIndexPath = indexPath
                
                // tableview 구성하는 함수 추가해야함
                
                mogakCategoryFirstLoaded.toggle()
            }
            
            cell.mogakNameLabel.text = mogakTitleList[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            let selectedCell = collectionView.cellForItem(at: indexPath) as! SegmentCollectionViewCell
            
            selectedCell.isSelected = true
            // 선택된 셀의 텍스트 색 변경, 언더라인 보이게
            selectedCell.textLabel.textColor = UIColor(hex: "24252E")
            //selectedCell.underLineView.isHidden = false
            selectedCell.underLineView.fadeIn()
            
            // 이전에 선택된 셀이 있다면 텍스트 색 변경, 언더라인 안보이게
            if let prevSelectedIndexPath = selectedSmallModalartIndexPath, prevSelectedIndexPath != indexPath {
                if let prevSelectedCell = collectionView.cellForItem(at: prevSelectedIndexPath) as? SegmentCollectionViewCell {
                    prevSelectedCell.isSelected = false
                    prevSelectedCell.textLabel.textColor = UIColor(hex: "BFC3D4")
                    //prevSelectedCell.underLineView.isHidden = true
                    prevSelectedCell.underLineView.fadeOut()
                }
            }
            
            // 선택된 셀의 인덱스를 저장
            selectedSmallModalartIndexPath = indexPath
            
            mogakCategoryFirstLoaded = false
            
            self.mogakTitleList = titlesForSelectedCategory(selectedCategory: selectedCell.textLabel.text!, groupedCategories: groupedMogakData)
            self.mogakCategoryCollectionView.reloadData()
            
        }
        else if collectionView.tag == 2 {
            let selectedCell = collectionView.cellForItem(at: indexPath) as! MogakCategoryDetailCollectionViewCell
            
            selectedCell.isSelected = true
            selectedCell.mogakNameLabel.textColor = UIColor(hex: "F1F3FA")
            selectedCell.mogakNameView.backgroundColor = UIColor(hex: "24252E")
            // tableview 구성하는 함수 추가해야함
            
            // 이전에 선택된 셀이 있다면 텍스트 색 변경, 뷰 하얗게
            if let prevSelectedIndexPath = selectedMogakCategoryIndexPath, prevSelectedIndexPath != indexPath {
                if let prevSelectedCell = collectionView.cellForItem(at: prevSelectedIndexPath) as? MogakCategoryDetailCollectionViewCell {
                    prevSelectedCell.isSelected = false
                    prevSelectedCell.mogakNameLabel.textColor = UIColor(hex: "BFC3D4")
                    prevSelectedCell.mogakNameView.backgroundColor = UIColor(hex: "FFFFFF")
                }
            }
            
            // 선택된 셀의 인덱스를 저장
            selectedMogakCategoryIndexPath = indexPath
            
            configureTableViewData(forSelectedItem: smallModalartList[indexPath.item])
            listTableView.reloadData()
        }
    }
    
    private func configureTableViewData(forSelectedItem selectedItem: String) {
        // segmentcollectionview 선택된 항목에 따라 listTableview data를 설정
        switch selectedItem {
        case smallModalartList[0]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "직무", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "직무", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "직무", "3회차", "00ABE1"]
            ]
        case smallModalartList[1]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "자격증", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "자격증", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "자격증", "3회차", "00ABE1"]
            ]
        case smallModalartList[2]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "시험", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "시험", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "시험", "3회차", "00ABE1"]
            ]
        case smallModalartList[3]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "건강", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "건강", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "건강", "3회차", "00ABE1"]
            ]
        case smallModalartList[4]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "카테고리", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "카테고리", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "카테고리", "3회차", "00ABE1"]
            ]
        case smallModalartList[5]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "진행중", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "진행중", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "진행중", "3회차", "00ABE1"]
            ]
        case smallModalartList[6]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "진행중", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "진행중", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "진행중", "3회차", "00ABE1"]
            ]
        case smallModalartList[7]:
            tableViewData = [
                ["DDF7FF", "자격증 공부 1시간", "진행중", "1회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "진행중", "2회차", "00ABE1"],
                ["DDF7FF", "자격증 공부 1시간", "진행중", "3회차", "00ABE1"]
            ]
        default:
            break
        }
    }
}

extension MyHistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SegmentCollectionViewCell else {
                return .zero
            }
            cell.textLabel.sizeToFit()
            cell.underLineView.sizeToFit()
            
            let cellWidth = cell.textLabel.frame.width + 64
            
            return CGSize(width: cellWidth, height: 46)
        }
        else if collectionView.tag == 2 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mogakCategoryCell", for: indexPath) as? MogakCategoryDetailCollectionViewCell else {
                return .zero
            }
            cell.mogakNameLabel.sizeToFit()
            cell.mogakNameView.sizeToFit()
            
            let cellWidth = cell.mogakNameLabel.frame.width + 64
            return CGSize(width: 100, height: 43)
        }
        return .zero
    }
}

extension MyHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableViewData.count
        
//        switch segmentControl.selectedSegmentIndex {
//        case 0:
//            return progressCount == 0 ? 1 : progressCount
//        case 1:
//            return failCount == 0 ? 1 : failCount
//        case 2:
//            return successCount == 0 ? 1 : successCount
//        default:
//            break
//        }
//        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ListTableViewCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        cell.parentViewController = self
        
        cell.configure(backColor: UIColor(hex: "\(tableViewData[indexPath.row][0])"), titleText: tableViewData[indexPath.row][1], statusText: tableViewData[indexPath.row][2], categoryText: tableViewData[indexPath.row][3], statusTextColor: UIColor(hex: "\(tableViewData[indexPath.row][4])"))
        
        
        
        
//        switch segmentControl.selectedSegmentIndex {
//        case 0:
//            cell.configure(backColor: UIColor(hex: "E8EBFE"), titleText: "progress", statusText: "진행중", categoryText: "자격증", statusTextColor: UIColor(hex: "475FFD"))
//        case 1:
//            cell.configure(backColor: UIColor(hex: "FFDEDE"), titleText: "fail", statusText: "실패", categoryText: "공모전", statusTextColor: UIColor(hex: "FF2323"))
//        case 2:
//            cell.configure(backColor: UIColor(hex: "E7F9F3"), titleText: "success", statusText: "성공", categoryText: "자격증", statusTextColor: UIColor(hex: "009967"))
//        default:
//            break
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ListTableViewCell else {
            return
        }
        let memoirVC = MemoirDetailViewController()
        // timeUsed -> 회차로 수정
        if let title = cell.titleLabel.text,
           let smallGoal = cell.smallGoalLabel.text,
           let date = cell.dateLabel.text {
            memoirVC.configureMemoirData(category: smallGoal, timeUsed: "1회차", jogakName: title, date: date, memoirText: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!! 오늘은 11월 14일,, 제 생일입니다.오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!! 오늘은 11월 14일,, 제 생일입니다.오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!! 오늘은 11월 14일,, 제 생일입니다.")
        }
        memoirVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(memoirVC, animated: true)
//        let detailVC = JogakDetailViewController()
//
//        if let status = cell.smallGoalLabel.text,
//           let category = cell.episodeLabel.text,
//           let title = cell.titleLabel.text,
//           let color = cell.smallGoalView.backgroundColor,
//           let textColor = cell.smallGoalLabel.textColor
//        {
//            detailVC.configureData(color: color, status: status, category: category, title: title, textColor: textColor)
//        }
//        detailVC.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(detailVC, animated: true)
        //        self.present(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

//@available(iOS 17.0, *)
//#Preview("MyHistoryVC") {
//    MyHistoryViewController()
//}

extension UIView {
    
    func fadeIn(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }
    
    func fadeOut(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }
    
}

extension MyHistoryViewController {
    
}



// MARK: - Extension : 배열 중복 제거
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
