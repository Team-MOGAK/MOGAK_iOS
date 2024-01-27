//
//  MogakEditViewController.swift
//  MOGAK
//
//  Created by 이재혁 on 12/7/23.
//

import UIKit
import SnapKit
import Then
import ReusableKit
import FSCalendar
import Alamofire

class MogakEditViewController: UIViewController {
    weak var delegate: MogakCreatedReloadDelegate?
    let mogakNetwork = MogakNetwork()
    
    // MARK: - 데이터
    private var currentModalartId: Int = 0
    var currentMogakId: Int = 0
    var currentBigCategory: String = ""
    var currentSmallCategory: String? = nil
    var mogakData: [MogakMainData] = []
    
    var currentStartDate: String = ""
    var currentEndDate: String = ""
    var currentColor: String = ""
    
    let titleColorPalette: [String] = ["475FFD", "FF4C77", "F98A08", "11D796", "FF6827", "9C31FF", "21CAFF", "FF2F2F"]
    
    private var isColorSelected: Bool = false
    
    private var categorySelectedList = ""
    private var repeatSelectedList : [String] = []
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    // 달력 현재 페이지
    private var currentPage: Date?
    private var endCurrentPage: Date?
    
    var selectedCategoryIndexPath: IndexPath?
    var selectedRepeatIndexPath: IndexPath?
    
    // 선택된 셀의 인덱스를 저장하는 Set
    var selectedRepeatIndexPaths = Set<IndexPath>()
    
    private var contentHeightConstraint: Constraint?
    
    
    private let today: Date = {
        return Date()
    }()
    
    enum Reusable {
        static let categoryCell = ReusableCell<CategoryCell>()
        static let repeatCell = ReusableCell<RepeatCell>()
    }
    
    // 스크롤뷰
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .white
    }
    
    private let contentView = DismissKeyboardView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - 모각 이름
    private let mogakLabel : UILabel = {
        let label = UILabel()
        label.text = "모각 이름"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    let mogakTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "하고 싶은 루틴의 제목을 입력해주세요."
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.borderStyle = .none
        //        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        return textField
    }()
    
    private let mogakUnderLineView : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    // MARK: - 카테고리
    private let categoryLabel : UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        label.textColor = UIColor(hex: "24252E")
        return label
    }()
    
    private let categoryExplanationLabel: UILabel = {
        let label = UILabel()
        label.text = "루틴이 속하는 분류를 선택해주세요."
        label.font = UIFont.pretendard(.regular, size: 14)
        label.textColor = UIColor(hex: "6E707B")
        return label
    }()
    
    let categoryList: [String] = [
        "자격증", "대외활동", "운동", "인사이트",
        "공모전", "직무공부", "산업분석", "어학",
        "강연,강의", "프로젝트", "스터디", "기타"
    ]
    
    let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        $0.isScrollEnabled = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.register(Reusable.categoryCell)
    }
    
    private let etcTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "카테고리 이름을 적어주세요."
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.borderStyle = .none
        //        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        
        textField.isHidden = true
        return textField
    }()
    
    private let etcUnderLineView : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        view.layer.borderWidth = 1
        
        view.isHidden = true
        return view
    }()
    
    // MARK: - 기간 선택
    private let repeatLabel = UILabel().then {
        $0.text = "기간선택"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let termExplanationLabel = UILabel().then {
        $0.text = "언제 시작하고 언제까지 유지할지 선택해주세요."
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.textColor = UIColor(hex: "6E707B")
    }
    
    private lazy var toggleButton = UISwitch().then {
        $0.isOn = false
        $0.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
    }
    
    private let repeatList: [String] = [
        "월", "화", "수", "목","금",
        "토", "일"
    ]
    
    private let repeatCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8 // 상하간격
        layout.minimumInteritemSpacing = 8 // 좌우간격
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        $0.isScrollEnabled = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.register(Reusable.repeatCell)
    }
    
    // MARK: - 날짜선택
    
    private let choiceColorLabel = UILabel().then {
        $0.text = "색상 선택"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    
    private let startLabel = UILabel().then {
        $0.text = "시작"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.isHidden = true
    }
    
    private let startTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.textColor = UIColor(hex: "475FFD")
        textField.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "yyyy/mm/dd(요일)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BFC3D4"), .font: UIFont.pretendard(.medium, size: 16)])
        textField.isHidden = true
        return textField
    }()
    
    private let startCalendar : FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.weekdayHeight = 15
        calendar.headerHeight = 0
        calendar.transitionCoordinator.cachedMonthSize.height = 193
        //        calendar.appearance.eventSelectionColor = UIColor(hex: "FF0000")
        calendar.appearance.weekdayFont = UIFont.pretendard(.regular, size: 12)
        calendar.appearance.weekdayTextColor = UIColor(hex: "000000")
        
        calendar.appearance.titleDefaultColor = UIColor(hex: "200E04")
        calendar.appearance.titleTodayColor = UIColor(hex: "200E04")
        calendar.appearance.titleSelectionColor = UIColor(hex: "FFFFFF")
        calendar.appearance.titleFont = UIFont.pretendard(.medium, size: 16)
        
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = UIColor(hex: "475FFD")
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scope = .month
        
        calendar.isHidden = true
        return calendar
    }()
    
    private let headerTitle = UILabel().then {
        $0.text = "2023년 8월"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 18)
        $0.isHidden = true
    }
    
    private lazy var startPreviousButton : UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "24252E")
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(startPrevCurrentPage), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let testLabel = UILabel().then{
        $0.font = DesignSystemFont.bold22L100.value
        $0.textColor = DesignSystemColor.signature.value
    }
    
    private let testView = UIImageView().then {
        $0.image = UIImage(named: DesignSystemIcon.circleCheckmark.imageName)
    }
    
    private lazy var startNextButton : UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "24252E")
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(startNextCurrentPage), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // 종료 달력
    
    private let endLabel = UILabel().then {
        $0.text = "종료"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.medium, size: 16)
        $0.isHidden = true
    }
    
    private let endTextField : UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        textField.textColor = UIColor(hex: "475FFD")
        textField.placeholder = "yyyy/mm/dd(요일)"
        textField.attributedPlaceholder = NSAttributedString(string: "yyyy/mm/dd(요일)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BFC3D4"), .font: UIFont.pretendard(.medium, size: 16)])
        textField.isHidden = true
        return textField
    }()
    
    private let endCalendar : FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.weekdayHeight = 15
        calendar.headerHeight = 0
        calendar.transitionCoordinator.cachedMonthSize.height = 193
        //        calendar.appearance.eventSelectionColor = UIColor(hex: "FF0000")
        calendar.appearance.weekdayFont = UIFont.pretendard(.regular, size: 12)
        calendar.appearance.weekdayTextColor = UIColor(hex: "000000")
        
        calendar.appearance.titleDefaultColor = UIColor(hex: "200E04")
        calendar.appearance.titleTodayColor = UIColor(hex: "200E04")
        calendar.appearance.titleSelectionColor = UIColor(hex: "FFFFFF")
        calendar.appearance.titleFont = UIFont.pretendard(.medium, size: 16)
        
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = UIColor(hex: "475FFD")
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scope = .month
        
        calendar.isHidden = true
        return calendar
    }()
    
    private let endHeaderTitle = UILabel().then {
        $0.text = "2023년 8월"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 18)
        $0.isHidden = true
    }
    
    private lazy var endPreviousButton : UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "24252E")
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(endPrevCurrentPage), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var endNextButton : UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(hex: "24252E")
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(endNextCurrentPage), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var completeButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: "#475FFD")
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Color select Collectionview
    var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.configureView()
        self.configureNavBar()
        self.configureMogakTop()
        self.configureCategory()
        //self.configureRepeat()
        //self.configureDate()
        //self.configureEndDate()
        self.configureColorCollectionView()
        
        let today = startCalendar.today!
        self.headerTitle.text = setYearAndMonth(of: today)
        self.endHeaderTitle.text = setYearAndMonth(of: today)
        
        self.configureCompleteButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
//        categoryCollectionView.selectItem(at: [0, categoryList.firstIndex(of: currentBigCategory)!], animated: false, scrollPosition: .init())
//        collectionView(categoryCollectionView.self, didSelectItemAt: IndexPath(item: categoryList.firstIndex(of: currentBigCategory)!, section: 0))
//        
//        colorCollectionView.selectItem(at: [0, titleColorPalette.firstIndex(of: currentColor)!], animated: false, scrollPosition: .init())
//        collectionView(colorCollectionView.self, didSelectItemAt: IndexPath(item: titleColorPalette.firstIndex(of: currentColor)!, section: 0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        categoryCollectionView.selectItem(at: [0, categoryList.firstIndex(of: currentBigCategory)!], animated: false, scrollPosition: .init())
        collectionView(categoryCollectionView.self, didSelectItemAt: IndexPath(item: categoryList.firstIndex(of: currentBigCategory)!, section: 0))
        
        colorCollectionView.selectItem(at: [0, titleColorPalette.firstIndex(of: currentColor)!], animated: false, scrollPosition: .init())
        collectionView(colorCollectionView.self, didSelectItemAt: IndexPath(item: titleColorPalette.firstIndex(of: currentColor)!, section: 0))

    }
    
    private func configureColorCollectionView() {
        colorCollectionView.register(MogakInitColorCell.self, forCellWithReuseIdentifier: MogakInitColorCell.identifier)
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.tag = 3
        
        contentView.addSubview(choiceColorLabel)
        contentView.addSubview(colorCollectionView)
        
        choiceColorLabel.snp.makeConstraints({
            //$0.top.equalTo(self.repeatCollectionView.snp.bottom).offset(40)
            //$0.top.equalTo(self.termExplanationLabel.snp.bottom).offset(40)
            $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        colorCollectionView.snp.makeConstraints({
            $0.top.equalTo(choiceColorLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(40)
        })
    }
    
    private func configureView() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.backgroundColor = .white
        contentView.backgroundColor = .white
        
        scrollView.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        })
        
        contentView.snp.makeConstraints({
            $0.top.equalTo(self.scrollView.snp.top)
            $0.leading.equalTo(self.scrollView.snp.leading)
            $0.trailing.equalTo(self.scrollView.snp.trailing)
            $0.width.equalToSuperview().multipliedBy(1.0)
            $0.bottom.equalTo(self.scrollView.snp.bottom)
            $0.height.greaterThanOrEqualTo(self.scrollView.snp.height)
        })
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.title = "모각 수정"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.pretendard(.semiBold, size: 18)]
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
    }
    
    private func configureMogakTop() {
        [mogakLabel, mogakTextField, mogakUnderLineView].forEach({contentView.addSubview($0)})
        self.mogakTextField.delegate = self
        
        mogakLabel.snp.makeConstraints({
            $0.top.equalTo(self.contentView.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
        
        mogakTextField.snp.makeConstraints({
            $0.top.equalTo(self.mogakLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        mogakUnderLineView.snp.makeConstraints({
            $0.top.equalTo(self.mogakTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        })
    }
    
    private func configureCategory() {
        [categoryLabel, categoryCollectionView, categoryExplanationLabel].forEach({contentView.addSubview($0)})
        [etcTextField, etcUnderLineView].forEach({contentView.addSubview($0)})
        
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        self.categoryCollectionView.tag = 1
        
        self.etcTextField.delegate = self
        
        categoryLabel.snp.makeConstraints({
            $0.top.equalTo(self.mogakUnderLineView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        categoryExplanationLabel.snp.makeConstraints({
            $0.top.equalTo(self.categoryLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        })
        
        categoryCollectionView.snp.makeConstraints({
            $0.top.equalTo(self.categoryExplanationLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160)
        })
        
        etcTextField.snp.makeConstraints({
            $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        etcUnderLineView.snp.makeConstraints({
            $0.top.equalTo(self.etcTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        })
    }
    
    private func configureRepeat() {
        [repeatLabel, toggleButton, repeatCollectionView, termExplanationLabel].forEach({contentView.addSubview($0)})
        self.repeatCollectionView.delegate = self
        self.repeatCollectionView.dataSource = self
        self.repeatCollectionView.tag = 2
        
        repeatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeightConstraint = repeatCollectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint.isActive = true
        
        repeatLabel.snp.makeConstraints({
            $0.top.equalTo(self.etcUnderLineView.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        })
        
        toggleButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalTo(self.repeatLabel.snp.centerY)
            $0.width.equalTo(60)
            $0.height.equalTo(26)
        })
        
        termExplanationLabel.snp.makeConstraints({
            $0.top.equalTo(self.repeatLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        })
        
        repeatCollectionView.snp.makeConstraints({
            $0.top.equalTo(self.termExplanationLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-80)
            $0.height.equalTo(116)
        })
    }
    
    private func configureDate() {
        [startLabel, startTextField].forEach({contentView.addSubview($0)})
        [headerTitle, startPreviousButton, startNextButton].forEach({contentView.addSubviews($0)})
        [startCalendar].forEach({contentView.addSubview($0)})
        self.startTextField.delegate = self
        self.startCalendar.delegate = self
        
        startLabel.snp.makeConstraints({
            //$0.top.equalTo(self.choiceDateLabel.snp.bottom).offset(30)
            $0.top.equalTo(self.termExplanationLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        })
        
        startTextField.snp.makeConstraints({
            $0.centerY.equalTo(self.startLabel.snp.centerY)
            $0.leading.equalTo(self.startLabel.snp.trailing).offset(19)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        })
        
        
        startPreviousButton.snp.makeConstraints({
            $0.top.equalTo(self.startLabel.snp.bottom).offset(43)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(16)
            $0.height.equalTo(0)
        })
        
        headerTitle.snp.makeConstraints({
            $0.centerY.equalTo(self.startPreviousButton.snp.centerY)
            $0.leading.equalTo(self.startPreviousButton.snp.trailing).offset(4)
            $0.height.equalTo(0)
        })
        
        startNextButton.snp.makeConstraints({
            $0.centerY.equalTo(self.startPreviousButton.snp.centerY)
            $0.leading.equalTo(self.headerTitle.snp.trailing).offset(4)
            $0.width.height.equalTo(16)
            $0.height.equalTo(0)
        })
        
        startCalendar.snp.makeConstraints({
            $0.top.equalTo(self.headerTitle.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0)
        })
        
        
    }
    
    private func configureEndDate() {
        [endLabel, endTextField].forEach({contentView.addSubviews($0)})
        [endHeaderTitle, endPreviousButton, endNextButton, endCalendar].forEach({contentView.addSubviews($0)})
        self.endTextField.delegate = self
        self.endCalendar.delegate = self
        
        endLabel.snp.makeConstraints({
            $0.top.equalTo(self.startLabel.snp.bottom).offset(52)
            $0.leading.equalToSuperview().offset(20)
        })
        
        endTextField.snp.makeConstraints({
            $0.centerY.equalTo(self.endLabel.snp.centerY)
            $0.leading.equalTo(self.endLabel.snp.trailing).offset(19)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        })
        
        endPreviousButton.snp.makeConstraints({
            $0.top.equalTo(self.endLabel.snp.bottom).offset(43)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(16)
        })
        
        endHeaderTitle.snp.makeConstraints({
            $0.centerY.equalTo(self.endPreviousButton.snp.centerY)
            $0.leading.equalTo(self.endPreviousButton.snp.trailing).offset(4)
        })
        
        endNextButton.snp.makeConstraints({
            $0.centerY.equalTo(self.endPreviousButton.snp.centerY)
            $0.leading.equalTo(self.endHeaderTitle.snp.trailing).offset(4)
            $0.width.height.equalTo(16)
        })
        
        endCalendar.snp.makeConstraints({
            $0.top.equalTo(self.endHeaderTitle.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(212)
        })
        
    }
    
    private func configureCompleteButton() {
        self.contentView.addSubview(completeButton)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        completeButton.snp.makeConstraints({
            //            $0.bottom.equalTo(self.scrollView.frameLayoutGuide.snp.bottom).offset(-24)
            //$0.top.equalTo(colorCollectionView.snp.bottom).offset(28)
            $0.bottom.equalToSuperview().offset(-24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        })
        
    }
    
    // MARK: - objc
    
    // MARK: - toggle
    @objc private func toggleSwitchChanged(_ sender: UISwitch) {
        // 토글 스위치의 상태에 따라 collectionView와 끝 텍스트필드 종료 상태를 변경
        
        repeatCollectionView.isHidden = true
        startLabel.isHidden = !sender.isOn
        startTextField.isHidden = !sender.isOn
        endTextField.isHidden = !sender.isOn
        endLabel.isHidden = !sender.isOn
        if !sender.isOn {
            [startNextButton, headerTitle, startPreviousButton, startCalendar].forEach({$0.isHidden = true})
            
            startPreviousButton.snp.remakeConstraints({
                $0.top.equalTo(self.startLabel.snp.bottom).offset(43)
                $0.leading.equalToSuperview().offset(20)
                $0.width.equalTo(16)
                $0.height.equalTo(0)
            })
            
            headerTitle.snp.remakeConstraints({
                $0.centerY.equalTo(self.startPreviousButton.snp.centerY)
                $0.leading.equalTo(self.startPreviousButton.snp.trailing).offset(4)
                $0.height.equalTo(0)
            })
            
            startNextButton.snp.remakeConstraints({
                $0.centerY.equalTo(self.startPreviousButton.snp.centerY)
                $0.leading.equalTo(self.headerTitle.snp.trailing).offset(4)
                $0.width.height.equalTo(16)
                $0.height.equalTo(0)
            })
            
            startCalendar.snp.remakeConstraints({
                $0.top.equalTo(self.headerTitle.snp.bottom).offset(22)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(0)
            })
            
            [endNextButton, endHeaderTitle, endPreviousButton, endCalendar].forEach({$0.isHidden = true})
            
            endPreviousButton.snp.remakeConstraints({
                $0.top.equalTo(self.endLabel.snp.bottom).offset(43)
                $0.leading.equalToSuperview().offset(20)
                $0.width.height.equalTo(16)
            })
            
            endHeaderTitle.snp.remakeConstraints({
                $0.centerY.equalTo(self.endPreviousButton.snp.centerY)
                $0.leading.equalTo(self.endPreviousButton.snp.trailing).offset(4)
            })
            
            endNextButton.snp.remakeConstraints({
                $0.centerY.equalTo(self.endPreviousButton.snp.centerY)
                $0.leading.equalTo(self.endHeaderTitle.snp.trailing).offset(4)
                $0.width.height.equalTo(16)
            })
            
            endCalendar.snp.remakeConstraints({
                $0.top.equalTo(self.endHeaderTitle.snp.bottom).offset(22)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(212)
            })
            
            choiceColorLabel.snp.remakeConstraints({
                $0.top.equalTo(termExplanationLabel.snp.bottom).offset(40)
                $0.leading.equalToSuperview().inset(20)
            })
            
            completeButton.snp.remakeConstraints({
                $0.bottom.equalToSuperview().offset(-24)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            })
            
            self.view.layoutIfNeeded()
        } else {
            choiceColorLabel.snp.remakeConstraints({
                $0.top.equalTo(endTextField.snp.bottom).offset(40)
                $0.leading.equalToSuperview().inset(20)
            })
            
            completeButton.snp.remakeConstraints({
                //            $0.bottom.equalTo(self.scrollView.frameLayoutGuide.snp.bottom).offset(-24)
                $0.bottom.equalToSuperview().offset(-24)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
                $0.top.equalTo(colorCollectionView.snp.bottom).offset(28)
            })
            
            endLabel.snp.remakeConstraints({
                $0.top.equalTo(startLabel.snp.bottom).offset(52)
                $0.leading.equalToSuperview().offset(20)
                $0.width.equalTo(28)
            })
            
            self.view.layoutIfNeeded()
        }
        
        // 변경된 상태에 따라 collectionView의 높이 애니메이션과 함께 조절
        UIView.animate(withDuration: 0.3) {
            //self.collectionViewHeightConstraint.constant = sender.isOn ? 110 : 0 // 원하는 높이로 조절
            
            if !self.startCalendar.isHidden {
                let text = self.endLabel.text ?? ""
                let textSize = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: self.endLabel.bounds.height),
                                                               options: .usesLineFragmentOrigin,
                                                               attributes: [NSAttributedString.Key.font: self.endLabel.font!],
                                                               context: nil).size
                
                self.endLabel.snp.remakeConstraints({
                    $0.top.equalTo(self.startCalendar.snp.bottom).offset(16)
                    $0.leading.equalToSuperview().offset(20)
                    $0.width.equalTo(textSize.width)
                })
                
                self.endTextField.snp.makeConstraints({
                    $0.centerY.equalTo(self.endLabel.snp.centerY)
                    $0.leading.equalTo(self.endLabel.snp.trailing).offset(19)
                    $0.trailing.equalToSuperview().offset(-20)
                    $0.height.equalTo(52)
                })
                
                self.choiceColorLabel.snp.remakeConstraints({
                    $0.top.equalTo(self.endCalendar.snp.bottom).offset(40)
                    $0.leading.equalToSuperview().offset(20)
                })
                
            }
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc private func startNextCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = 1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.startCalendar.setCurrentPage(self.currentPage!, animated: true)
        
        // DateFormatter를 사용하여 "YYYY년 M월" 형식으로 변환하여 출력
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 M월"
        if let formattedDate = self.currentPage {
            let formattedString = dateFormatter.string(from: formattedDate)
            //            print("이번 달 \(formattedString)")
            headerTitle.text = formattedString
        } else {
            print("이번 달 날짜 없음")
        }
    }
    
    @objc private func startPrevCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.startCalendar.setCurrentPage(self.currentPage!, animated: true)
        
        // DateFormatter를 사용하여 "YYYY년 M월" 형식으로 변환하여 출력
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 M월"
        if let formattedDate = self.currentPage {
            let formattedString = dateFormatter.string(from: formattedDate)
            //            print("이번 달 \(formattedString)")
            headerTitle.text = formattedString
        } else {
            print("이번 달 날짜 없음")
        }
    }
    
    @objc private func endNextCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = 1
        
        self.endCurrentPage = cal.date(byAdding: dateComponents, to: self.endCurrentPage ?? self.today)
        self.endCalendar.setCurrentPage(self.endCurrentPage!, animated: true)
        
        // DateFormatter를 사용하여 "YYYY년 M월" 형식으로 변환하여 출력
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 M월"
        if let formattedDate = self.endCurrentPage {
            let formattedString = dateFormatter.string(from: formattedDate)
            endHeaderTitle.text = formattedString
        } else {
            print("이번 달 날짜 없음")
        }
    }
    
    @objc private func endPrevCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        self.endCurrentPage = cal.date(byAdding: dateComponents, to: self.endCurrentPage ?? self.today)
        self.endCalendar.setCurrentPage(self.endCurrentPage!, animated: true)
        
        // DateFormatter를 사용하여 "YYYY년 M월" 형식으로 변환하여 출력
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 M월"
        if let formattedDate = self.endCurrentPage {
            let formattedString = dateFormatter.string(from: formattedDate)
            //            print("이번 달 \(formattedString)")
            endHeaderTitle.text = formattedString
        } else {
            print("이번 달 날짜 없음")
        }
    }
    
    /* @objc private func completeButtonTapped() {
        if let title = mogakTextField.text,
           let start = startTextField.text,
           let end = endTextField.text {
            var shortStart = String(start.dropLast(5))
            var shortEnd = String(end.dropLast(5))
            let startComponents = shortStart.components(separatedBy: "/")
            let endComponents = shortEnd.components(separatedBy: "/")
            
            if startComponents.count >= 2, let year = Int(startComponents[0]), let month = Int(startComponents[1]) {
                var modifiedMonth: String = ""
                
                // 조건에 따라 월을 변환
                //                if 1...9 ~= month {
                //                    modifiedMonth = "0\(month)"
                //                }
                if 1...9 ~= month {
                    modifiedMonth = "0\(month)"
                }
                
                // 변환된 월을 2자리 숫자로 포맷
                //                let formattedMonth = String(format: "%02d", modifiedMonth)
                
                // 최종 결과 생성
                shortStart = "\(year)-\(modifiedMonth)-\(startComponents[2])"
                print("\(shortStart)") // 출력 결과: "2023/08/14"
            } else {
                print("Invalid date format")
            }
            
            if endComponents.count >= 2, let year = Int(endComponents[0]), let month = Int(endComponents[1]) {
                var modifiedMonth: String = "\(month)"
                
                // 조건에 따라 월을 변환
                if 1...9 ~= month {
                    modifiedMonth = "0\(month)"
                }
                
                // 변환된 월을 2자리 숫자로 포맷
                //                let formattedMonth = String(format: "%02d", modifiedMonth)
                
                // 최종 결과 생성
                shortEnd = "\(year)-\(modifiedMonth)-\(endComponents[2])"
                print("\(shortEnd)") // 출력 결과: "2023/08/14"
            } else {
                print("Invalid date format")
            }
            
            var days: [String] = []
            
            switch self.repeatSelectedList[0] {
            case "월":
                days.append("MONDAY")
            case "화":
                days.append("TUESDAY")
            case "수":
                days.append("WEDNESDAY")
            case "목":
                days.append("THURSDAY")
            case "금":
                days.append("FRIDAY")
            case "토":
                days.append("SATURDAY")
            case "일":
                days.append("SUNDAY")
            default:
                days.append("MONDAY")
            }
            
            initMogak(title: title, category: categorySelectedList, days: days, start: shortStart, end: shortEnd)
            print("title \(title) start \(shortStart) end \(shortEnd) days \(days) category \(categorySelectedList)")
        } else {
            print("버튼 옵셔널 해제 실패")
        }
    } */
    @objc private func completeButtonTapped() {
        //createMogak()
        editMogak()
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - 익스텐션

extension MogakEditViewController: UITextFieldDelegate {
    // 리턴 키 입력 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // 키보드 안 올라오게
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == startTextField { // 시작날짜
            [startNextButton, headerTitle, startPreviousButton, startCalendar].forEach({$0.isHidden = false})
            [endNextButton, endHeaderTitle, endPreviousButton, endCalendar].forEach({$0.isHidden = true})
            
            let text = endLabel.text ?? ""
            let textSize = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: endLabel.bounds.height),
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [NSAttributedString.Key.font: endLabel.font!],
                                                           context: nil).size
            
            headerTitle.snp.remakeConstraints({
                $0.centerX.equalToSuperview()
                //                $0.centerY.equalTo(self.startPreviousButton.snp.centerY)
                $0.top.equalTo(self.startLabel.snp.bottom).offset(43)
                $0.leading.equalTo(self.startPreviousButton.snp.trailing).offset(4)
            })
            
            startPreviousButton.snp.remakeConstraints({
                //                $0.top.equalTo(self.startLabel.snp.bottom).offset(43)
                $0.centerY.equalTo(self.headerTitle.snp.centerY)
                //                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalTo(self.headerTitle.snp.leading).offset(-4)
                $0.width.height.equalTo(16)
            })
            
            startNextButton.snp.remakeConstraints({
                $0.centerY.equalTo(self.startPreviousButton.snp.centerY)
                $0.leading.equalTo(self.headerTitle.snp.trailing).offset(4)
                $0.width.height.equalTo(16)
            })
            
            startCalendar.snp.remakeConstraints({
                $0.top.equalTo(self.headerTitle.snp.bottom).offset(22)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(212)
            })
            
            
            completeButton.snp.remakeConstraints({
                $0.top.equalTo(self.startCalendar.snp.bottom).offset(100)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            })
            
            startLabel.snp.remakeConstraints({
                //$0.top.equalTo(self.choiceDateLabel.snp.bottom).offset(55)
                $0.top.equalTo(self.termExplanationLabel.snp.bottom).offset(20)
                $0.leading.equalToSuperview().offset(20)
                //$0.width.equalTo(startTextSize.width)
                $0.width.equalTo(28)
            })
            
            endLabel.snp.remakeConstraints({
                $0.top.equalTo(self.startCalendar.snp.bottom).offset(50)
                $0.leading.equalToSuperview().offset(20)
                //$0.width.equalTo(textSize.width)
                $0.width.equalTo(28)
            })
            
            endTextField.snp.makeConstraints({
                $0.centerY.equalTo(self.endLabel.snp.centerY)
                $0.leading.equalTo(self.endLabel.snp.trailing).offset(19)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(52)
            })
            
            choiceColorLabel.snp.remakeConstraints({
                $0.top.equalTo(endTextField.snp.bottom).offset(40)
                $0.leading.equalToSuperview().offset(20)
            })
            
//            contentView.snp.makeConstraints({
//                $0.bottom.equalTo(completeButton.snp.bottom).offset(16)
//            })
            colorCollectionView.snp.remakeConstraints({
                $0.top.equalTo(choiceColorLabel.snp.bottom).offset(10)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview()
                $0.height.equalTo(40)
            })
            
            completeButton.snp.remakeConstraints({
                $0.top.equalTo(colorCollectionView.snp.bottom).offset(30)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview().offset(-22)
            })
            
            
        } else if textField == endTextField { // 종료날짜
            [startNextButton, headerTitle, startPreviousButton, startCalendar].forEach({$0.isHidden = true})
            
            [endNextButton, endHeaderTitle, endPreviousButton, endCalendar].forEach({$0.isHidden = false})
            //Get the size of the text to be displayed in the endLabel
            let text = endLabel.text ?? ""
            let textSize = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: endLabel.bounds.height),
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [NSAttributedString.Key.font: endLabel.font!],
                                                           context: nil).size
            
            let startText = startLabel.text ?? ""
            let startTextSize = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: startLabel.bounds.height),
                                                                options: .usesLineFragmentOrigin,
                                                                attributes: [NSAttributedString.Key.font: startLabel.font!],
                                                                context: nil).size
            
            startLabel.snp.remakeConstraints({
                //$0.top.equalTo(self.choiceDateLabel.snp.bottom).offset(55)
                $0.top.equalTo(self.termExplanationLabel.snp.bottom).offset(20)
                $0.leading.equalToSuperview().offset(20)
                //$0.width.equalTo(startTextSize.width)
                $0.width.equalTo(28)
            })
            
            startTextField.snp.makeConstraints({
                $0.centerY.equalTo(self.startLabel.snp.centerY)
                $0.leading.equalTo(self.startLabel.snp.trailing).offset(19)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(52)
            })
            
            endLabel.snp.remakeConstraints({
                $0.top.equalTo(self.startLabel.snp.bottom).offset(52)
                $0.leading.equalToSuperview().offset(20)
                //$0.width.equalTo(textSize.width)
                $0.width.equalTo(28)
            })
            
            endTextField.snp.makeConstraints({
                $0.centerY.equalTo(self.endLabel.snp.centerY)
                $0.leading.equalTo(self.endLabel.snp.trailing).offset(19)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(52)
            })
            
            endHeaderTitle.snp.remakeConstraints({
                $0.top.equalTo(self.endTextField.snp.bottom).offset(24)
                $0.centerX.equalToSuperview()
                $0.leading.equalTo(self.startPreviousButton.snp.trailing).offset(4)
            })
            
            endPreviousButton.snp.remakeConstraints({
                $0.centerY.equalTo(self.endHeaderTitle.snp.centerY)
                $0.trailing.equalTo(self.endHeaderTitle.snp.leading).offset(-4)
                $0.width.height.equalTo(16)
            })
            
            endNextButton.snp.remakeConstraints({
                $0.centerY.equalTo(self.endPreviousButton.snp.centerY)
                $0.leading.equalTo(self.endHeaderTitle.snp.trailing).offset(4)
                $0.width.height.equalTo(16)
            })
            
            endCalendar.snp.remakeConstraints({
                $0.top.equalTo(self.endHeaderTitle.snp.bottom).offset(22)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(212)
            })
            
            completeButton.snp.remakeConstraints({
                //$0.top.equalTo(self.endCalendar.snp.bottom).offset(16)
                $0.top.equalTo(colorCollectionView.snp.bottom).offset(30)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            })
            
            choiceColorLabel.snp.remakeConstraints({
                $0.top.equalTo(endCalendar.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
            })
            
//            contentView.snp.remakeConstraints({
//                $0.bottom.equalTo(completeButton.snp.bottom).offset(30)
//                $0.width.equalToSuperview().multipliedBy(1.0)
//            })
            
            colorCollectionView.snp.remakeConstraints({
                $0.top.equalTo(choiceColorLabel.snp.bottom).offset(10)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview()
                $0.height.equalTo(40)
            })
            
            completeButton.snp.remakeConstraints({
                $0.top.equalTo(colorCollectionView.snp.bottom).offset(30)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview().offset(-22)
            })
        } else if textField == mogakTextField {
            return true
        } else if textField == etcTextField {
            return true
        }
        return false
    }
    
}



extension MogakEditViewController: UICollectionViewDataSource {
    // cell갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return categoryList.count
        } else if collectionView.tag == 2 {
            return repeatList.count
        } else if collectionView.tag == 3 {
            return titleColorPalette.count
        }
        //        return categoryList.count
        return 3
    }
    
    // cell 선언
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let cell = collectionView.dequeue(Reusable.categoryCell, for: indexPath)
            cell.textLabel.text = categoryList[indexPath.item]
            return cell
        } else if collectionView.tag == 2 {
            let cell = collectionView.dequeue(Reusable.repeatCell, for: indexPath)
            cell.textLabel.text = repeatList[indexPath.item]
            return cell
        } else if collectionView.tag == 3 {
            guard let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier:  MogakInitColorCell.identifier, for: indexPath) as? MogakInitColorCell else {return UICollectionViewCell()}
            
            cell.color = UIColor(hex: titleColorPalette[indexPath.row])
//                    if titleColorPalette[indexPath.row] == titleBgColor { //만약에 지금 보여줘야 하는 셀이 타이틀 백그라운드 색이랑 같다면 해당 컬러차트 표시
//                        isColorSelected = true
//                        cell.innerView.backgroundColor = .white
//                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
//                        changeCompleteBtn()
//                    }
                    
                    cell.setUpColorView()
                    cell.setUpInnerView()
                    
                    return cell
        }
        
        return UICollectionViewCell()
        //        let cell = collectionView.dequeue(Reusable.categoryCell, for: indexPath)
        //
        //        cell.textLabel.text = categoryList[indexPath.item]
        //        return cell
    }
}

extension MogakEditViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            let selectedCell = collectionView.cellForItem(at: indexPath) as! CategoryCell
            
            // 선택된 셀의 배경색 변경
            selectedCell.contentView.backgroundColor = UIColor(hex: "475FFD")
            selectedCell.textLabel.textColor = UIColor(hex: "FFFFFF")
            self.currentBigCategory = selectedCell.textLabel.text!
            print(currentBigCategory)
            
            // 이전에 선택된 셀이 있다면 배경색 변경
            if let prevSelectedIndexPath = selectedCategoryIndexPath, prevSelectedIndexPath != indexPath {
                if let prevSelectedCell = collectionView.cellForItem(at: prevSelectedIndexPath) as? CategoryCell {
                    prevSelectedCell.contentView.backgroundColor = UIColor(hex: "F1F3FA")
                    prevSelectedCell.textLabel.textColor = UIColor(hex: "24252E")
                }
            }
            
            // 선택된 셀의 인덱스를 저장
            selectedCategoryIndexPath = indexPath
            selectedRepeatIndexPath = nil
            
            if let cellText = selectedCell.textLabel.text {
                categorySelectedList = cellText
            }
            print("클릭 시 categorySelectedList === \(categorySelectedList)")
            
            // 기타 카테고리 선택 시 텍스트필드 뜨도록
            if indexPath.item == categoryList.count - 1 {
                // 마지막 셀인 경우, UITextField hidden 속성을 해제
                [etcTextField, etcUnderLineView].forEach({$0.isHidden = false})
                
                choiceColorLabel.snp.remakeConstraints({
                    $0.top.equalTo(self.etcUnderLineView.snp.bottom).offset(40)
                    $0.leading.equalToSuperview().offset(20)
                })
                
                self.view.layoutIfNeeded()
            }
            else {
                [etcTextField, etcUnderLineView].forEach({$0.isHidden = true})
                
                choiceColorLabel.snp.remakeConstraints({
                    $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(40)
                    $0.leading.equalToSuperview().offset(20)
                })
                
                self.view.layoutIfNeeded()
            }
            
        } else if collectionView.tag == 2 {
            let selectedCell = collectionView.cellForItem(at: indexPath) as! RepeatCell
            
            // 이미 선택된 셀인지 확인
            if selectedRepeatIndexPaths.contains(indexPath) {
                // 이미 선택된 셀의 경우 선택 해제 처리
                selectedCell.contentView.backgroundColor = UIColor(hex: "EEF0F8")
                selectedCell.textLabel.textColor = UIColor(hex: "24252E")
                selectedRepeatIndexPaths.remove(indexPath)
                if let index = repeatSelectedList.firstIndex(of: selectedCell.textLabel.text ?? "") {
                    repeatSelectedList.remove(at: index)
                }
            } else {
                // 선택되지 않은 셀의 경우 선택 처리
                selectedCell.contentView.backgroundColor = UIColor(hex: "475FFD")
                selectedCell.textLabel.textColor = UIColor(hex: "FFFFFF")
                selectedRepeatIndexPaths.insert(indexPath)
                if let cellText = selectedCell.textLabel.text {
                    repeatSelectedList.append(cellText)
                }
            }
            print("클릭 시 repeatSelectedList === \(repeatSelectedList)")
            
        } else if collectionView.tag == 3 {
            if !isColorSelected {
                isColorSelected = true
            }
            currentColor = titleColorPalette[indexPath.row]
            print(currentColor)
        }
    }
}

extension MogakEditViewController: UICollectionViewDelegateFlowLayout {
    // 셀 크기설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 {
            let label = UILabel().then {
                $0.font = UIFont.pretendard(.medium, size: 14)
                $0.text = categoryList[indexPath.item]
                $0.sizeToFit()
            }
            let size = label.frame.size
            
            return CGSize(width: size.width + 40, height: size.height + 16)
        } else if collectionView.tag == 2 {
            let label = UILabel().then {
                $0.font = UIFont.pretendard(.medium, size: 16)
                $0.text = repeatList[indexPath.item]
                $0.sizeToFit()
            }
            let size = label.frame.size
            
            return CGSize(width: size.width + 37, height: size.height + 32)
            
        } else if collectionView.tag == 3 {
            return CGSize(width: 40, height: 40)
        }
        return CGSize()
    }
}
// MARK: - 캘린더 관련

extension MogakEditViewController {
    private func setYearAndMonth(of date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        let dateString = formatter.string(from: date)
        return dateString
    }
}

extension MogakEditViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if calendar == startCalendar {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/M/d(EEE)"
            let selectedDateStr = dateFormatter.string(from: date)
            print("시작 Selected Date: \(selectedDateStr)")
            startTextField.text = selectedDateStr
            
            // api 통신을 위한 2nd dateFormatter
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "yyyy-MM-dd"
            let selectedStartDateStr = dateFormatter2.string(from: date)
            print("api통신 위한 시작 Date: \(selectedStartDateStr)")
            currentStartDate = selectedStartDateStr
            
        } else if calendar == endCalendar {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/M/d(EEE)"
            let selectedDateStr = dateFormatter.string(from: date)
            print("종료 Selected Date: \(selectedDateStr)")
            endTextField.text = selectedDateStr
            
            // api 통신을 위한 2nd dateFormatter
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "yyyy-MM-dd"
            let selectedEndDateStr = dateFormatter2.string(from: date)
            print("api통신 위한 종료 Date: \(selectedEndDateStr)")
            currentEndDate = selectedEndDateStr
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let date = calendar.currentPage
        let formatter = DateFormatter()
        // 년과 월을 출력하기 위한 포맷 설정
        formatter.dateFormat = "yyyy년 M월"
        let dateString = formatter.string(from: date)
        
        if calendar == startCalendar {
            self.headerTitle.text = dateString
        } else if calendar == endCalendar {
            self.endHeaderTitle.text = dateString
        }
    }
}
// MARK: - 통신 코드

extension MogakEditViewController {
    // 모각 생성
    // MARK: - 재혁 코드
    func editMogak() {
        //let id = currentModalartId
        let id = currentMogakId
        let editedTitle = mogakTextField.text
        let bigCategory = currentBigCategory
        var smallCategory = currentSmallCategory
        //smallCategory = etcTextField.text! ?? nil
        //var startAt: String = currentStartDate
        //var endAt: String = currentEndDate
        var color: String = "#" + currentColor
        
        //
        //
        //        let data = MogakMainData(modaratId: id, title: createdTitle!, bigCategory: bigCategory, smallCategory: smallCategory, startAt: startAt, endAt: endAt, color: color)
        
        let editedData = EditMogakRequestMainData(mogakId: id, title: editedTitle!, bigCategory: currentBigCategory, smallCategory: smallCategory, color: color)
        print("\(editedData)")
        
        mogakNetwork.editMogak(data: editedData) {
            result in
            switch result {
            case .success(let mogakEditedData):
                print(#fileID, #function, #line, "- editedMogakData: \(mogakEditedData)")
                self.delegate?.reloadModalart()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print(#fileID, #function, #line, "- error: \(error.localizedDescription)")
            }
        }
        //self.navigationController?.popToViewController(, animated: false)
    }
    
    
    // MARK: - 이전 버전(강현님 코드)
//    func initMogak(title: String, category: String, days: [String], start: String, end: String) {
//        let path = "/api/mogaks"
//        
//        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else { return }
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(accessToken)",
//            "accept": "application/json",
//            "Content-Type": "application/json"
//        ]
//        
//        let parameters: [String: Any] = [
//            "title": title,
//            "category": category,
//            "days": days,
//            "startAt": start,
//            "endAt": end
//        ]
//        
//        NetworkManager.shared.post(path: path, parameters: parameters, headers: headers) { response in
//            switch response.result {
//            case .success(let data):
//                guard let jsonData = data else {
//                    print("No data received")
//                    return
//                }
//                if let responseModel = try? JSONDecoder().decode(MogakInitModel.self, from: jsonData) {
//                    print("모각 생성 완료 \(responseModel)")
//                    self.navigationController?.popViewController(animated: true)
//                } else {
//                    print("디코딩 실패")
//                }
//            case .failure(let error):
//                print("실패 \(error)")
//                print("token \(accessToken)")
//                debugPrint(response)
//            }
//        }
//    }
    
}
