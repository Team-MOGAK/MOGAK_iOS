//
//  RoutineStartViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import SnapKit
import SwiftUI
import Alamofire
import Kingfisher

class NetworkingViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - PROPERTIES
    var scrollView: UIScrollView!
    
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
        
        let allTitle = "전체"
        let paceMakerTitle = "페이스메이커"
        
        segment.insertSegment(withTitle: allTitle, at: 0, animated: true)
        segment.insertSegment(withTitle: paceMakerTitle, at: 1, animated: true)
        
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
    
    //: SEGMENT
    
    // MARK: - TABLE VIEW
    private lazy var listTableView : UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(hex: "EEF0F8")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        //tableView.separatorColor = .red
        tableView.backgroundColor = UIColor(.white)
        return tableView
    }()
    
    private func configureTableView() {
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.register(NetworkingFeedTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(listTableView)
        
        listTableView.snp.makeConstraints({
            $0.top.equalTo(self.filtersContainerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
        
    }
    
    
    // MARK: - FILTERS
    private let filtersContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        
        return view
    }()
    
    private lazy var locationFilterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.pretendard(.regular, size: 14)
        button.setTitle("경기도", for: .normal)
        button.setTitleColor(UIColor(hex: "24252E"), for: .normal)
        //button.tintColor = UIColor(hex: "F1F3FA")
        button.backgroundColor = UIColor(hex: "F1F3FA")
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        
        button.addTarget(self, action: #selector(showLocationFilterSheetView(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var categoryFilterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.pretendard(.regular, size: 14)
        button.setTitle("프로젝트", for: .normal)
        button.setTitleColor(UIColor(hex: "24252E"), for: .normal)
        button.tintColor = UIColor(hex: "F1F3FA")
        button.backgroundColor = UIColor(hex: "F1F3FA")
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        return button
    }()
    
    private let pullDownButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(systemName: "chevron.down", withConfiguration: config)
        
        button.configuration = UIButton.Configuration.borderless()
        button.configuration?.image = image
        button.configuration?.imagePadding = 3
        
        button.titleLabel?.font = UIFont.pretendard(.semiBold, size: 14)
        button.setTitle("최신순", for: .normal)
        button.setTitleColor(UIColor(hex: "808497"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = UIColor(hex: "808497")
        
        // 버튼 탭할 시 메뉴 생성
        
        let newest = UIAction(title: "최신순", handler: { _ in print("최신순")})
        
        let popular = UIAction(title: "인기순", handler: { _ in print("인기순")})
        
        button.menu = UIMenu(identifier: nil, options: .displayInline, children: [newest, popular])
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = UIColor(hex: "F1F3FA")
        view.backgroundColor = .white
        //view.safeAreaLayoutGuide.owningView?.backgroundColor = .gray
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.configureSegment()
        //self.view.sendSubviewToBack(self.navigationController?.navigationBar ?? UIView())
        self.configureFilter()
        self.configureTableView()
        self.setUpFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
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
    
    // MARK: - configure segment
    private func configureSegment() {
        view.addSubview(containerView)
        containerView.addSubview(segmentControl)
        containerView.addSubview(underLineView)
        
        let statusBarHeight: CGFloat
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight),
            containerView.heightAnchor.constraint(equalToConstant: 48),
            
            
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
    
    // MARK: - Configure Filter
    private func configureFilter() {
        self.view.addSubview(filtersContainerView)
        filtersContainerView.addSubview(locationFilterButton)
        filtersContainerView.addSubview(categoryFilterButton)
        filtersContainerView.addSubview(pullDownButton)
        //filtersContainerView.backgroundColor = .blue
        filtersContainerView.snp.makeConstraints({
            $0.top.equalTo(containerView.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(view).inset(0)
            $0.height.equalTo(30)
        })
        
        locationFilterButton.snp.makeConstraints({
            //$0.top.equalTo(filtersContainerView.snp.top).offset(4)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(filtersContainerView).offset(20)
            //$0.trailing.equalTo(categoryFilterButton).offset(-10)
            $0.height.equalTo(26)
        })
        
        categoryFilterButton.snp.makeConstraints({
            //$0.top.equalTo(filtersContainerView.snp.top).offset(4)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(filtersContainerView).offset(83)
            //$0.trailing.equalTo(filtersContainerView).offset(-5)
            $0.height.equalTo(26)
        })
        
        pullDownButton.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(filtersContainerView).offset(-10)
            $0.height.equalTo(21)
        })
        
    }
    
    enum SegmentCurrent {
        case All
        case Pacemakers
    }
    var selectedSegment = SegmentCurrent.All
    
    
    // MARK: - BottomSheet
    @objc private func showLocationFilterSheetView(_ sender: UIButton) {
        
        let navigationController = UINavigationController(rootViewController: LocationFilterSheetView())
        
        navigationController.isNavigationBarHidden = true
        
        // 이곳에서 테이블 뷰 셀을 가져올 수 있습니다.
        if let cell = self.listTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NetworkingFeedTableViewCell {
            // 커스텀 셀로 다운캐스팅하여 profileImageView에 접근
            print("cell 이미지 컬러 - \(String(describing: cell.profileImageView.tintColor))")
            cell.profileImageView.tintColor = UIColor.systemBlue
            
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - 페이스메이커 게시글 불러오기 API
    var PacemakerFeedData = [FeedModel]()
    
    func PacemakerFeedsGET(completion: @escaping([PacemakerFeedsResponse.Result]?) -> Void) {
//        guard let jwt_token = "Bearer " + UserDefaults.standard.value(forKey: "accessToken") else {
//            completion(nil)
//            return
//        }
        
//        let token = UserDefaults.standard.value(forKey: "accessToken") as! String
        
//        guard let token = UserDefaults.standard.value(forKey: "accessToken") as? String else {
//            print("ERROR TOKEN")
//            completion(nil)
//            return
//        }
        
//        let jwt_token: String = "Bearer " + token
        let jwt_token: String = "Bearer " + "eyJ0eXBlIjoiand0IiwiYWxnIjoiSFMyNTYifQ.eyJ1c2VyUGsiOiIxIiwiaWF0IjoxNjkyNzIyNDEwLCJleHAiOjE3MjQyNTg0MTB9.sqb4ioXK5fTGz7CRzL1ZBZ9yxDvBwIUfY-Azbo3aVuM"
        
        print("jwt token : \(jwt_token)")
        let headers: HTTPHeaders = [
            "Authorization": jwt_token
        ]
        
        let params = [
            "cursor": 0,
            "size": 5
        ]
        
        AF.request("http://43.200.36.231:8080/api/posts/pacemakers",
                   method: .get,
                   parameters: params,
                   //encoding: JSONEncoding.default,
                   encoding: URLEncoding.default,
                   headers: headers)
        .responseDecodable(of: PacemakerFeedsResponse.self) { response in
            switch response.result {
            case .success(let serverResponse):
                print(serverResponse)
                completion(serverResponse.result)
            case .failure(let error):
                print("ERROR: \(error)")
                completion(nil)
            }
        }
    } //: PacemakerFeedsGET()
    
    func setUpFeed() {
        PacemakerFeedsGET() { result in
            guard let result = result else {
                print("Failed to get feed data.")
                return
            }
            
            DispatchQueue.main.async {
                for post in result {
                    print("\(post.user.nickname), \(post.user.job), \(post.user.address), \(post.imgUrls[0]),\n 피드글: \(post.contents)\n")
                    self.PacemakerFeedData.append(FeedModel(
                        userName: post.user.nickname,
                        category: post.user.job,
                        feedImageURL: post.imgUrls[0],
                        feedContent: post.contents,
                        likeCnt: post.likeCnt,
                        messageCnt: post.comments.count))
                }
            }
        }
    } //: setUpFeed()
}


extension NetworkingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (segmentControl.selectedSegmentIndex) {
        case 0:
            return 2
        case 1:
            return PacemakerFeedData.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? NetworkingFeedTableViewCell else {return UITableViewCell()}
        
        switch (segmentControl.selectedSegmentIndex) {
        case 0:
            cell.selectionStyle = .none
            return cell
        case 1:
            cell.selectionStyle = .none
            let target = PacemakerFeedData[indexPath.row]
            
            cell.configure(nameText: target.userName, categoryText: target.category, feedText: target.feedContent, likeCnt: target.likeCnt, messageCnt: target.messageCnt, feedImageURL: target.feedImageURL)
            
            return cell
        default:
            break
        }
        //cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
}

extension LocationFilterSheetView: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        
    }
}



// MARK: - PREVIEW
//Preview code
//#if DEBUG
//import SwiftUI
//struct MainBoardViewControllerRepresentable: UIViewControllerRepresentable {
//    
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        NetworkingViewController() //<- 수정
//    }
//}
//@available(iOS 13.0, *)
//struct ViewControllerRepresentable_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            if #available(iOS 14.0, *) {
//                MainBoardViewControllerRepresentable()
//                    .ignoresSafeArea()
//                    .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//                    .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//        
//    }
//} #endif


/*
 switch (segment.selectedSegmentIndex) {
 case 0:
     //First segment tapped
     print("전체 Tapped")
     selectedSegment = .All
     //self.listTableView.reloadData()
     self.listTableView.reloadData()
     
 case 1:
     //Second segment tapped
     print("페이스메이커 Tapped")
     selectedSegment = .Pacemakers
     self.listTableView.reloadData()
     
 default:
     break
 }
 */

/*
 switch (selectedSegment) {
 case .All:
     // First segment tapped
     return 3
 case .Pacemakers:
     // Second segment tapped
     return 2
 }
 */
