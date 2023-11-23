//
//  MemoirDetailViewController.swift
//  MOGAK
//
//  Created by 이재혁 on 11/13/23.
//

import UIKit
import SnapKit
import Then

class MemoirDetailViewController: UIViewController {
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
        $0.isUserInteractionEnabled = true
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
    
    // 직무 라벨
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
        //button.setImage(UIImage(named: "ellipsis_vertical"), for: .normal)
        
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(hex: "6E707B")
        //button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        //button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(ellipsisButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - 수정/삭제 버튼
    @objc private func ellipsisButtonTapped() {
        print("TAPPED")
        let alertController: UIAlertController
        
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정하기", style: .default) { _ in
            // Edit action
            let navigationController = UINavigationController(rootViewController: ConfirmEdittingSheetViewController())
            
            navigationController.isNavigationBarHidden = true
            
            self.present(navigationController, animated: true, completion: nil)
            //self.parentViewController?.present(navigationController, animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { _ in
            // Delete action
            let navigationController = UINavigationController(rootViewController: ConfirmDeletingFeedSheetViewController())
            
            navigationController.isNavigationBarHidden = true
            
            self.present(navigationController, animated: true, completion: nil)
            //self.parentViewController?.present(navigationController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel, handler: nil)
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        //self.parentViewController?.present(alertController, animated: true, completion: nil)
        present(alertController, animated: true, completion: nil)
    }
    
//    // MARK: - 수정 버튼 탭(삭제될지도)
//    @objc private func editButtonTapped() {
//        let alertController: UIAlertController
//        if 1 + 1 == 2 { // 나중에 추가
//            // 내 게시물인 경우
//            alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            let editAction = UIAlertAction(title: "수정하기", style: .default) { _ in
//                // Edit action
//                let navigationController = UINavigationController(rootViewController: ConfirmEdittingSheetViewController())
//                
//                navigationController.isNavigationBarHidden = true
//                
//                self.present(navigationController, animated: true, completion: nil)
//            }
//            let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { _ in
//                // Delete action
//                let navigationController = UINavigationController(rootViewController: ConfirmDeletingFeedSheetViewController())
//                
//                navigationController.isNavigationBarHidden = true
//                
//                self.present(navigationController, animated: true, completion: nil)
//            }
//            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
//            alertController.addAction(editAction)
//            alertController.addAction(deleteAction)
//            alertController.addAction(cancelAction)
//        } else {
//            // 다른 계정의 게시물인 경우
//            alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            let reportAction = UIAlertAction(title: "신고하기", style: .destructive) { _ in
//                // Report action
//            }
//            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
//            alertController.addAction(reportAction)
//            alertController.addAction(cancelAction)
//        }
//        present(alertController, animated: true, completion: nil)
//    }
    
    /**
     GPT를 통해 물어본 내 게시글, 타인 게시글에 따라 다른 ACTION SHEET 예시 코드
     @IBAction func buttonTapped(_ sender: UIButton) {
     let alertController: UIAlertController
     if post.authorID == currentUserID {
     // 내 게시물인 경우
     alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
     let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
     // Edit action
     }
     let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
     // Delete action
     }
     let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
     alertController.addAction(editAction)
     alertController.addAction(deleteAction)
     alertController.addAction(cancelAction)
     } else {
     // 다른 계정의 게시물인 경우
     alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
     let reportAction = UIAlertAction(title: "Report", style: .destructive) { _ in
     // Report action
     }
     let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
     alertController.addAction(reportAction)
     alertController.addAction(cancelAction)
     }
     present(alertController, animated: true, completion: nil)
     }
     
     */
    
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
            $0.top.equalToSuperview() // 나중에 offset 바꾸기
            $0.height.equalTo(68)
        })
        
        topContainerView.addSubviews(profileContainerView, editButton)
        
        profileContainerView.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(128)
            $0.height.equalTo(36)
        })
        
        editButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        })
    }
    
    // MARK: - 프로필 컨테이너 <- addsubviews
    private func configureProfileElements() {
        profileContainerView.addSubviews(nameLabel, profileImageView, categoryLabel)
        
        profileImageView.snp.makeConstraints({
            //            $0.top.bottom.left.equalToSuperview()
            //            $0.width.equalTo(profileContainerView.frame.height)
            $0.top.bottom.left.equalTo(profileContainerView).inset(0)
            $0.width.height.equalTo(36)
        })

        nameLabel.snp.makeConstraints({
            $0.bottom.equalTo(profileContainerView.snp.centerY).offset(2)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
        })
        
        categoryLabel.snp.makeConstraints({
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(profileContainerView.snp.centerY).offset(4)
        })
    }
    
    // MARK: - BODY (FEED IMAGE)
    let feedImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "cuteBokdol")
        //imageView.backgroundColor = .white
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    // MARK: - ADD FEED IMAGE
    private func configureFeedImage() {
        contentView.addSubview(feedImage)
        
        feedImage.snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.top.equalTo(topContainerView.snp.bottom)
            $0.height.equalTo(contentView.snp.width)
        })
    }
    
    // MARK: - BODY (루틴 정보)
    private let routineInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "F1F3FA")
        view.layer.cornerRadius = 10
        return view
    }()
    
    // 루틴 카테고리
    private let routineCategoryLabel : BasePaddingLabel = {
        let label = BasePaddingLabel()
        // label.clipToBounds = true -> 왜 안돼?
        label.layer.masksToBounds = true // 위랑 같은 기능이라는데
        label.alpha = 0.8
        label.text = "대외활동"
        label.textAlignment = .center
        label.font = UIFont.pretendard(.semiBold, size: 14)
        label.textColor = UIColor(hex: "475FFD")
        label.layer.cornerRadius = 10
        label.backgroundColor = UIColor(hex: "FFFFFF")
        
        return label
    }()

    // 루틴 걸린시간
    private let routineOverallTimeLabel: UILabel = UILabel().then {
        $0.text = "1시간 20분"
        $0.textColor = UIColor(hex: "475FFD")
        $0.font = UIFont.pretendard(.regular, size: 14)
    }
    
    // 루틴 이름
    private let routineName: UILabel = UILabel().then {
        $0.text = "기획 아티클 읽기"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.medium, size: 16)
    }
    
    // 루틴 기간, 요일
    private let routineTerm: UILabel = UILabel().then {
        $0.text = "2024년 6월 5일"
        $0.textColor = UIColor(hex: "6E707B")
        $0.font = UIFont.pretendard(.regular, size: 14)
    }
    
    
    // MARK: - ADDSUBVIEW 루틴정보 캡슐
    private func configureRoutineInfo() {
        contentView.addSubview(routineInfoView)
        routineInfoView.snp.makeConstraints({
            $0.top.equalTo(feedImage.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(108)
        })
        
        routineInfoView.addSubview(routineCategoryLabel)
        routineCategoryLabel.snp.makeConstraints({
            $0.top.left.equalToSuperview().offset(16)
        })
        
        routineInfoView.addSubview(routineOverallTimeLabel)
        routineOverallTimeLabel.snp.makeConstraints({
            $0.top.equalToSuperview().offset(19)
            $0.left.equalTo(routineCategoryLabel.snp.right).offset(8)
        })
        
        routineInfoView.addSubview(routineName)
        routineName.snp.makeConstraints({
            $0.top.equalTo(routineCategoryLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().offset(16)
        })
        
        routineInfoView.addSubview(routineTerm)
        routineTerm.snp.makeConstraints({
            $0.top.equalTo(routineName.snp.bottom).offset(6)
            $0.left.right.equalToSuperview().offset(16)
        })
    }
    
    // MARK: - BODY (피드 텍스트)
    private let feedText: UILabel = UILabel().then {
        $0.textColor = UIColor(hex: "200E04")
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.numberOfLines = 0
        $0.alpha = 0.9
        
//        var paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineHeightMultiple = 1.26
//        paragraphStyle.lineBreakMode = .byCharWrapping
        //paragraphStyle.lineBreakStrategy = .hangulWordPriority
        $0.attributedText = NSMutableAttributedString(
            string: "오늘은 펀딩프로젝트에 대한 회고록을 작성했다. 예전에 했던 프로젝트에서 부족했던점과 느꼈던 점, 다양한 사람들과의 소통방식을 다시 되돌아보고 나의 경험을 하나씩 정리해가며 포트폴리오를 만들예정이다. 우리 모각러들도 항상 화이팅!!"//,
            //attributes: [.paragraphStyle: paragraphStyle]
        )
    }
    
    // MARK: - ADDSUBVIEW 피드 텍스트
    private func configureFeedText() {
        contentView.addSubview(feedText)
        feedText.snp.makeConstraints({
            $0.left.right.equalToSuperview().inset(20)
            $0.top.equalTo(routineInfoView.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
        })
    }
    
    func configureMemoirData(category: String, timeUsed: String, jogakName: String, date: String, memoirText: String) {
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        self.feedText.attributedText = NSMutableAttributedString(
            string: memoirText,
            attributes: [.paragraphStyle: paragraphStyle])
        self.routineCategoryLabel.text = category
        self.routineOverallTimeLabel.text = timeUsed
        self.routineName.text = jogakName
        self.routineTerm.text = date
    }
    
    //    // MARK: - TAIL CONTAINER VIEW
    //    private let tailContainerView: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = .white
    //        return view
    //    }()
    //
    //    var isHeartFilled: Bool = false
    //
    //    private let heartButton: UIButton = {
    //        let button = UIButton()
    //        button.setImage(UIImage(systemName: "heart"), for: .normal)
    //        button.tintColor = UIColor(hex: "24252E")
    //        button.isEnabled = true
    //
    //        button.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
    //
    //        return button
    //    }()
    //
    //    @objc private func heartButtonTapped() {
    //        isHeartFilled.toggle()
    //        // 디버깅용
    //        print("Tapped: heart Filled: \(isHeartFilled)")
    //
    //        if isHeartFilled {
    //            heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    //            heartButton.tintColor = UIColor(hex: "FF4D77")
    //        } else {
    //            heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
    //            heartButton.tintColor = UIColor(hex: "24252E")
    //        }
    //    }
    //
    //    private let heartRate: UILabel = {
    //        let label = UILabel()
    //        label.text = "7"
    //        label.font = UIFont.pretendard(.regular, size: 14)
    //        label.textColor = UIColor(hex: "24252E")
    //
    //        return label
    //    }()
    //
    //    private let messageButton: UIButton = {
    //        let button = UIButton()
    //        button.setImage(UIImage(systemName: "message"), for: .normal)
    //        button.tintColor = UIColor(hex: "24252E")
    //
    //        return button
    //    }()
    //
    //    private let messageRate: UILabel = {
    //        let label = UILabel()
    //        label.text = "2"
    //        label.font = UIFont.pretendard(.regular, size: 14)
    //        label.textColor = UIColor(hex: "24252E")
    //
    //        return label
    //    }()
    //
    //    // MARK: - ADDSUBVIEW (하트 등등)
    //    private func configureTailView() {
    //        contentView.addSubview(tailContainerView)
    //        tailContainerView.snp.makeConstraints({
    //            $0.top.equalTo(feedText.snp.bottom).offset(16)
    //            $0.left.right.equalToSuperview()
    //            $0.height.equalTo(32)
    //        })
    //
    //        tailContainerView.addSubviews(heartButton, heartRate, messageButton, messageRate)
    //
    //        heartButton.snp.makeConstraints({
    //            $0.left.equalToSuperview().offset(20)
    //            $0.centerY.equalToSuperview()
    //            $0.width.height.equalTo(24)
    //        })
    //        heartRate.snp.makeConstraints({
    //            $0.left.equalTo(heartButton.snp.right).offset(4)
    //            $0.centerY.equalToSuperview()
    //        })
    //        messageButton.snp.makeConstraints({
    //            $0.left.equalTo(heartRate.snp.right).offset(12)
    //            $0.centerY.equalToSuperview()
    //            $0.width.height.equalTo(24)
    //        })
    //        messageRate.snp.makeConstraints({
    //            $0.left.equalTo(messageButton.snp.right).offset(4)
    //            $0.centerY.equalToSuperview()
    //        })
    //    }
    //
    //    // MARK: - (게시글 - 댓글) divider
    //    private let dividerLineView: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = UIColor(hex: "EEF0F8")
    //        return view
    //    }()
    //
    //    // MARK: - ADDSUBVIEW divider
    //    private func configureDivider() {
    //        contentView.addSubview(dividerLineView)
    //        dividerLineView.snp.makeConstraints({
    //            $0.top.equalTo(tailContainerView.snp.bottom).offset(16)
    //            $0.left.right.equalToSuperview()
    //            $0.height.equalTo(2)
    //        })
    //    }
    //
    //    // MARK: - 댓글 tableview
    //    lazy var commentTableView: UITableView = {
    //        let tableView = UITableView()
    //        //let tableView = UITableView(frame: .zero, style: .plain)
    //        tableView.register(FeedDetailCommentTableViewCell.self, forCellReuseIdentifier: "FeedDetailCommentTableViewCell")
    //        tableView.delegate = self
    //        tableView.dataSource = self
    //        tableView.isScrollEnabled = false
    //
    //        tableView.translatesAutoresizingMaskIntoConstraints = false
    //        tableView.separatorStyle = .none
    //
    //        tableView.rowHeight = UITableView.automaticDimension
    //        tableView.estimatedRowHeight = UITableView.automaticDimension
    //        //tableView.tableFooterView = writingCommentFooterView
    //        return tableView
    //    }()
    //
    //    // MARK: - ADDSUBVIEW 댓글 tableview
    //    private func configureCommentTable() {
    //        contentView.addSubview(commentTableView)
    //        var count = FeedComment.data.count
    //        commentTableView.snp.makeConstraints({
    //            $0.top.equalTo(dividerLineView.snp.bottom).offset(24)
    //            $0.left.right.equalToSuperview().inset(20)
    //            //$0.bottom.equalTo(contentView.snp.bottom).offset(90)
    //            $0.height.equalTo(count * 140)
    //            $0.bottom.equalToSuperview()
    //        })
    //    }
    //
    //    // MARK: - 댓글쓰기 footer
    //    private let writingCommentFooterView: UIView = UIView().then {
    //        $0.backgroundColor = .white
    //        $0.frame.size.height = 50
    //    }
    //
    //    private let commentTextField: UITextField = UITextField().then {
    //        $0.placeholder = "모각러에게 응원의 한마디를 남겨주세요!"
    //        $0.font = UIFont.pretendard(.regular, size: 14)
    //        $0.borderStyle = UITextField.BorderStyle.roundedRect
    //        $0.autocorrectionType = UITextAutocorrectionType.no
    //        $0.keyboardType = UIKeyboardType.default
    //        $0.returnKeyType = UIReturnKeyType.done
    //        $0.clearButtonMode = UITextField.ViewMode.whileEditing
    //        $0.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
    //    }
    //
    //    private let registerCommentButton: UIButton = UIButton().then {
    //        $0.setTitle("작성", for: .normal)
    //        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 14)
    //        $0.setTitleColor(UIColor(hex: "FFFFFF"), for: .normal)
    //        $0.backgroundColor = UIColor(hex: "475FFD")
    //        $0.layer.cornerRadius = 10
    //        $0.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    //    }
    //
    //    lazy var commentTextView: UITextView = UITextView().then {
    //        $0.layer.masksToBounds = true
    //        $0.layer.cornerRadius = 10
    //        $0.backgroundColor = UIColor(hex: "EEF0F8")
    //        $0.autocorrectionType = UITextAutocorrectionType.no
    //        $0.keyboardType = UIKeyboardType.default
    //        $0.returnKeyType = UIReturnKeyType.done
    //        $0.font = UIFont.pretendard(.regular, size: 14)
    //        $0.text = "모각러에게 응원의 한마디를 남겨주세요!"
    //        $0.textColor = UIColor(hex: "808497")
    //        $0.textContainerInset.top = 10
    //        $0.delegate = self
    //        $0.isEditable = true
    //    }
    //
    //    private func configureFooterView() {
    //        writingCommentFooterView.addSubviews(commentTextView, registerCommentButton)
    //        commentTextView.snp.makeConstraints({
    //            $0.centerY.equalToSuperview()
    //            $0.left.equalToSuperview().inset(5)
    //            $0.right.equalToSuperview().inset(50)
    //            $0.height.equalTo(40)
    //        })
    //        registerCommentButton.snp.makeConstraints({
    //            //$0.bottom.equalTo(commentTextField.snp.bottom)
    //            $0.centerY.equalToSuperview()
    //            //$0.right.equalToSuperview().inset(5)
    //            $0.left.equalTo(commentTextView.snp.right).offset(5)
    //        })
    //    }
    //
    //    // MARK: - (나중에지울거) dividerforScroll
    //    private let dividerforScroll: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = UIColor(hex: "EEF0F8")
    //        return view
    //    }()
    //
    //    // MARK: - ADDSUBVIEW divider (나중에 지울거)
    //    private func configureDividerforScroll() {
    //        contentView.addSubview(dividerforScroll)
    //        dividerforScroll.snp.makeConstraints({
    //            $0.left.right.equalToSuperview()
    //            $0.height.equalTo(2)
    //            $0.top.equalTo(commentTableView).offset(10)
    //            $0.bottom.equalToSuperview()
    //        })
    //    }
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        
        configureNavBar()
        configureScrollView()
        configureTopContainer()
        configureProfileElements()
        configureFeedImage()
        configureRoutineInfo()
        configureFeedText()
        //configureTailView()
        //configureDivider()
        //configureCommentTable()
        //button.addTarget(self, action: #selector(ellipsisButtonTapped), for: .touchUpInside)
        //configureFooterView()
        //commentTableView.tableFooterView = writingCommentFooterView
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        // 키보드 업&다운 옵저버
    //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    //        self.navigationController?.isNavigationBarHidden = false
    //    }
    //
    //    override func viewWillDisappear(_ animated: Bool) {
    //        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    //        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    //        self.navigationController?.isNavigationBarHidden = false
    //    }
    //
    //    // 키보드 팝업하면 뷰를 올리는
    //    @objc func keyboardUp(notification:NSNotification) {
    //        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
    //            let keyboardRectangle = keyboardFrame.cgRectValue
    //
    //            UIView.animate(
    //                withDuration: 0.3
    //                , animations: {
    //                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
    //                }
    //            )
    //        }
    //    }
    //
    //    // 키보드 내려가면 원래대로
    //    @objc func keyboardDown() {
    //        self.view.transform = .identity
    //    }
    //}
    
    // MARK: - CUSTOM LABEL (for padding...)
    class BasePaddingLabel: UILabel {
        private var padding = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        
        convenience init(padding: UIEdgeInsets) {
            self.init()
            self.padding = padding
        }
        
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: padding))
        }
        
        override var intrinsicContentSize: CGSize {
            var contentSize = super.intrinsicContentSize
            contentSize.height += padding.top + padding.bottom
            contentSize.width += padding.left + padding.right
            
            return contentSize
        }
    }
}
//
//// MARK: TableViewDelegate, TableViewDataSource
//extension MemoirDetailViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return FeedComment.data.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: "FeedDetailCommentTableViewCell") as? FeedDetailCommentTableViewCell
//        else { return UITableViewCell() }
//
//        let dataObject = FeedComment.data[indexPath.row]
//
//        cell.configureCell(profileImage: dataObject.profileImage, name: dataObject.name, comment: dataObject.comment)
//
//        cell.selectionStyle = .none
//        return cell
//    }
//
//}
//
//// MARK: - UITEXTVIEW extension
//extension MemoirDetailViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        guard textView.textColor == UIColor(hex: "808497") else { return }
//        textView.text = nil
//        textView.textColor = .label
//    }
//}

 @available(iOS 17.0, *)
 #Preview("MemoirDetailVC") {
     MemoirDetailViewController()
 }
 
