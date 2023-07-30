//
//  MogakInitViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/07/23.
//

import UIKit
import SnapKit
import Then
import ReusableKit
import FSCalendar

class MogakInitViewController: UIViewController {
    
    private var categorySelectedList : [String] = []
    private var repeatSelectedList : [String] = []
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    // 달력 현재 페이지
    private var currentPage: Date?
    private var endCurrentPage: Date?
    
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
    
    private let mogakTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "조각 이름을 적어주세요"
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
    
    private let categoryList: [String] = [
        "자격증", "대외활동", "운동", "인사이트",
        "공모전", "직무공부", "산업분석", "어학",
        "강연/강의", "프로젝트", "스터디", "기타"
    ]
    
    private let categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        $0.isScrollEnabled = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.register(Reusable.categoryCell)
    }
    
    // MARK: - 반복 주기
    private let repeatLabel = UILabel().then {
        $0.text = "반복 주기"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = UIColor(hex: "24252E")
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
    
    private let choiceDateLabel = UILabel().then {
        $0.text = "날짜 선택"
        $0.textColor = UIColor(hex: "24252E")
        $0.font = UIFont.pretendard(.semiBold, size: 14)
    }
    
    private let startLabel = UILabel().then {
        $0.text = "시작"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.medium, size: 16)
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
        $0.text = "2023년 7월"
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
        $0.text = "2023년 7월"
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
        $0.backgroundColor = UIColor(hex: "BFC3D4")
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.pretendard(.medium, size: 18)
    }
    
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.configureView()
        self.configureNavBar()
        self.configureMogakTop()
        self.configureCategory()
        self.configureRepeat()
        self.configureDate()
        self.configureEndDate()
        self.configureCompleteButton()
    }
    
    private func configureView() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints({
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        })
        
        contentView.snp.makeConstraints({
            $0.top.equalTo(self.scrollView.contentLayoutGuide.snp.top)
            $0.leading.equalTo(self.scrollView.contentLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.scrollView.contentLayoutGuide.snp.trailing)
            $0.bottom.equalTo(self.scrollView.contentLayoutGuide.snp.bottom)
            $0.width.equalTo(self.scrollView.snp.width)
        })
        
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        // 컨텐츠가 뷰를 넘어갈 때만 스크롤이 가능하도록 설정
        //        contentView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }
    
    private func configureNavBar() {
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.title = "모각 생성"
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
        [categoryLabel, categoryCollectionView].forEach({contentView.addSubview($0)})
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        self.categoryCollectionView.tag = 1
        
        categoryLabel.snp.makeConstraints({
            $0.top.equalTo(self.mogakUnderLineView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        categoryCollectionView.snp.makeConstraints({
            $0.top.equalTo(self.categoryLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(110)
        })
    }
    
    private func configureRepeat() {
        [repeatLabel, toggleButton, repeatCollectionView].forEach({contentView.addSubview($0)})
        self.repeatCollectionView.delegate = self
        self.repeatCollectionView.dataSource = self
        self.repeatCollectionView.tag = 2
        
        repeatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeightConstraint = repeatCollectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint.isActive = true
        
        repeatLabel.snp.makeConstraints({
            $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        toggleButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalTo(self.repeatLabel.snp.centerY)
            $0.width.equalTo(60)
            $0.height.equalTo(26)
        })
        
        repeatCollectionView.snp.makeConstraints({
            $0.top.equalTo(self.repeatLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-99)
            $0.height.equalTo(110)
        })
    }
    
    private func configureDate() {
        [choiceDateLabel, startLabel, startTextField].forEach({contentView.addSubview($0)})
        [headerTitle, startPreviousButton, startNextButton].forEach({contentView.addSubviews($0)})
        [startCalendar].forEach({contentView.addSubview($0)})
        self.startTextField.delegate = self
        self.startCalendar.delegate = self
        
        choiceDateLabel.snp.makeConstraints({
            $0.top.equalTo(self.repeatCollectionView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        startLabel.snp.makeConstraints({
            $0.top.equalTo(self.choiceDateLabel.snp.bottom).offset(30)
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
            $0.width.height.equalTo(16)
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
            $0.height.equalTo(212)
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
        self.contentView.addSubviews(completeButton)
        
        completeButton.snp.makeConstraints({
            $0.bottom.equalTo(self.contentView.safeAreaLayoutGuide.snp.bottom).offset(-24)
            //            $0.top.equalTo(self.startTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            //            $0.bottom.equalToSuperview().offset(-24)
        })
        
        contentView.snp.makeConstraints({
            $0.bottom.greaterThanOrEqualTo(completeButton.snp.bottom).offset(16)
        })
    }
    
    // MARK: - objc
    
    @objc private func toggleSwitchChanged(_ sender: UISwitch) {
        // 토글 스위치의 상태에 따라 collectionView와 끝 텍스트필드 종료 상태를 변경
        repeatCollectionView.isHidden = !sender.isOn
        endTextField.isHidden = !sender.isOn
        endLabel.isHidden = !sender.isOn
        // 변경된 상태에 따라 collectionView의 높이 애니메이션과 함께 조절
        UIView.animate(withDuration: 0.3) {
            self.collectionViewHeightConstraint.constant = sender.isOn ? 110 : 0 // 원하는 높이로 조절
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
            //            print("이번 달 \(formattedString)")
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
    
}

// MARK: - 익스텐션

extension MogakInitViewController: UITextFieldDelegate {
    // 리턴 키 입력 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == startTextField {
            [startNextButton, headerTitle, startPreviousButton, startCalendar].forEach({$0.isHidden = false})
            // Get the size of the text to be displayed in the endLabel
            let text = endLabel.text ?? ""
            let textSize = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: endLabel.bounds.height),
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [NSAttributedString.Key.font: endLabel.font!],
                                                           context: nil).size
            
            startPreviousButton.snp.remakeConstraints({
                $0.top.equalTo(self.startLabel.snp.bottom).offset(43)
                $0.leading.equalToSuperview().offset(20)
                $0.width.height.equalTo(16)
            })
            
            headerTitle.snp.remakeConstraints({
                $0.centerY.equalTo(self.startPreviousButton.snp.centerY)
                $0.leading.equalTo(self.startPreviousButton.snp.trailing).offset(4)
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
                $0.top.equalTo(self.startCalendar.snp.bottom).offset(74)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            })
            
            
            endLabel.snp.remakeConstraints({
                $0.top.equalTo(self.startCalendar.snp.bottom).offset(40)
                $0.leading.equalToSuperview().offset(20)
                $0.width.equalTo(textSize.width)
            })
            
            endTextField.snp.makeConstraints({
                $0.centerY.equalTo(self.endLabel.snp.centerY)
                $0.leading.equalTo(self.endLabel.snp.trailing).offset(19)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(52)
            })
            
            contentView.snp.makeConstraints({
                $0.bottom.greaterThanOrEqualTo(endTextField.snp.bottom).offset(16)
            })
        } else if textField == endTextField {
            [endNextButton, endHeaderTitle, endPreviousButton, endCalendar].forEach({$0.isHidden = false})
            //Get the size of the text to be displayed in the endLabel
            let text = endLabel.text ?? ""
            let textSize = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: endLabel.bounds.height),
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [NSAttributedString.Key.font: endLabel.font!],
                                                           context: nil).size
            endLabel.snp.remakeConstraints({
                $0.top.equalTo(self.startCalendar.snp.bottom).offset(40)
                $0.leading.equalToSuperview().offset(20)
                $0.width.equalTo(textSize.width)
            })
            
            endTextField.snp.makeConstraints({
                $0.centerY.equalTo(self.endLabel.snp.centerY)
                $0.leading.equalTo(self.endLabel.snp.trailing).offset(19)
                $0.trailing.equalToSuperview().offset(-20)
                $0.height.equalTo(52)
            })
            
            completeButton.snp.remakeConstraints({
                $0.top.equalTo(self.endCalendar.snp.bottom).offset(74)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            })
            
            contentView.snp.remakeConstraints({
                $0.bottom.greaterThanOrEqualTo(endCalendar.snp.bottom).offset(30)
            })
        }
    }
}

extension MogakInitViewController: UICollectionViewDataSource {
    // cell갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return categoryList.count
        } else if collectionView.tag == 2 {
            return repeatList.count
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
        }
        
        return UICollectionViewCell()
        //        let cell = collectionView.dequeue(Reusable.categoryCell, for: indexPath)
        //
        //        cell.textLabel.text = categoryList[indexPath.item]
        //        return cell
    }
}

extension MogakInitViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1 {
            let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
            
            // 배경색 확인 및 변경
            if cell.contentView.backgroundColor == UIColor(hex: "F1F3FA") {
                // 셀이 클릭되지 않은 상태일 때, 클릭된 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "475FFD")
                cell.textLabel.textColor = UIColor(hex: "FFFFFF")
                // 셀 클릭 시 리스트에 카테고리 이름 추가
                if let cellText = cell.textLabel.text {
                    categorySelectedList.append(cellText)
                }
                print("클릭 시 categorySelectedList === \(categorySelectedList)")
            } else {
                // 셀이 이미 클릭된 상태일 때, 클릭되지 않은 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "F1F3FA")
                cell.textLabel.textColor = UIColor(hex: "24252E")
                if let cellText = cell.textLabel.text {
                    if categorySelectedList.contains(cellText) {
                        categorySelectedList.removeAll { element in
                            return element == cellText
                        }
                    }
                    print("다시 한 번 클릭 시 categorySelectedList === \(categorySelectedList)")
                }
            }
        } else if collectionView.tag == 2 {
            let cell = collectionView.cellForItem(at: indexPath) as! RepeatCell
            
            // 배경색 확인 및 변경
            if cell.contentView.backgroundColor == UIColor(hex: "EEF0F8") {
                // 셀이 클릭되지 않은 상태일 때, 클릭된 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "475FFD")
                cell.textLabel.textColor = UIColor(hex: "FFFFFF")
                // 셀 클릭 시 리스트에 카테고리 이름 추가
                if let cellText = cell.textLabel.text {
                    repeatSelectedList.append(cellText)
                }
                print("클릭 시 repeatSelectedList === \(repeatSelectedList)")
            } else {
                // 셀이 이미 클릭된 상태일 때, 클릭되지 않은 상태로 변경
                cell.contentView.backgroundColor = UIColor(hex: "EEF0F8")
                cell.textLabel.textColor = UIColor(hex: "24252E")
                if let cellText = cell.textLabel.text {
                    if repeatSelectedList.contains(cellText) {
                        repeatSelectedList.removeAll { element in
                            return element == cellText
                        }
                    }
                    print("다시 한 번 클릭 시 repeatSelectedList === \(repeatSelectedList)")
                }
            }
            
        }
        //        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        //
        //        // 배경색 확인 및 변경
        //        if cell.contentView.backgroundColor == UIColor(hex: "F1F3FA") {
        //            // 셀이 클릭되지 않은 상태일 때, 클릭된 상태로 변경
        //            cell.contentView.backgroundColor = UIColor(hex: "475FFD")
        //            cell.textLabel.textColor = UIColor(hex: "FFFFFF")
        //            // 셀 클릭 시 리스트에 카테고리 이름 추가
        //            if let cellText = cell.textLabel.text {
        //                categorySelectedList.append(cellText)
        //            }
        //            print("클릭 시 categorySelectedList === \(categorySelectedList)")
        //        } else {
        //            // 셀이 이미 클릭된 상태일 때, 클릭되지 않은 상태로 변경
        //            cell.contentView.backgroundColor = UIColor(hex: "F1F3FA")
        //            cell.textLabel.textColor = UIColor(hex: "24252E")
        //            if let cellText = cell.textLabel.text {
        //                if categorySelectedList.contains(cellText) {
        //                    categorySelectedList.removeAll { element in
        //                        return element == cellText
        //                    }
        //                }
        //                print("다시 한 번 클릭 시 categorySelectedList === \(categorySelectedList)")
        //            }
        //        }
    }
}

extension MogakInitViewController: UICollectionViewDelegateFlowLayout {
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
            
            return CGSize(width: size.width + 32, height: size.height + 32)
            
        }
        //        let label = UILabel().then {
        //            $0.font = UIFont.pretendard(.medium, size: 14)
        //            $0.text = categoryList[indexPath.item]
        //            $0.sizeToFit()
        //        }
        //        let size = label.frame.size
        //
        //        return CGSize(width: size.width + 40, height: size.height + 16)
        return CGSize()
    }
}

extension MogakInitViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if calendar == startCalendar {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/M/d(EEE)"
            let selectedDateStr = dateFormatter.string(from: date)
            print("시작 Selected Date: \(selectedDateStr)")
            startTextField.text = selectedDateStr
        } else if calendar == endCalendar {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/M/d(EEE)"
            let selectedDateStr = dateFormatter.string(from: date)
            print("종료 Selected Date: \(selectedDateStr)")
            endTextField.text = selectedDateStr
        }
        
        
        // 여기서 selectedDateStr을 원하는 대로 활용할 수 있습니다.
    }
}

