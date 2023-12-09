//
//  JogakInitViewController.swift
//  MOGAK
//
//  Created by 이재혁 on 12/7/23.
//

import UIKit
import UIKit
import SnapKit
import Then
import ReusableKit
import FSCalendar
import Alamofire

class JogakInitViewController: UIViewController {
    
    private let today: Date = {
        return Date()
    }()
    
    private var repeatSelectedList : [String] = []
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    var selectedRepeatIndexPath: IndexPath?
    
    // first date in the range
    private var firstDate: Date?
    // last date in the range
    private var lastDate: Date?
    
    private var datesRange: [Date]?
    
    // 달력 현재 페이지
    private var currentPage: Date?
    private var endCurrentPage: Date?
    
    // 선택된 셀의 인덱스를 저장하는 Set
    var selectedRepeatIndexPaths = Set<IndexPath>()
    
    private var contentHeightConstraint: Constraint?
    
    enum Reusable {
        static let repeatCell = ReusableCell<RepeatCell>()
    }
    
    // 스크롤뷰
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .white
    }
    
    private let contentView = DismissKeyboardView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - 모각 카테고리
    private let mogakCategoryTitleLabel : UILabel = {
        let label = UILabel()
        label.text = "모각 카테고리"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    //
    let mogakCategoryView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor(hex: "DDF7FF")
        return view
    }()
    
    let mogakCategoryLabel : UILabel = {
        let label = UILabel()
        label.text = "건강"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    func configure(backColor: UIColor, textColor: UIColor, text: String) {
        mogakCategoryView.backgroundColor = backColor
        mogakCategoryLabel.textColor = textColor
        mogakCategoryLabel.text = text
    }
    
    // MARK: - 조각 세부 제목
    private let jogakDetailTitleLabel : UILabel = {
        let label = UILabel()
        label.text = "조각 세부 제목"
        label.font = UIFont.pretendard(.semiBold, size: 14)
        return label
    }()
    
    private let jogakDetailTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "세부 제목을 적어주세요"
        textField.font = UIFont.pretendard(.medium, size: 16)
        textField.borderStyle = .none
        //        textField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        textField.leftViewMode = .unlessEditing
        return textField
    }()
    
    private let jogakDetailUnderLineView : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(hex: "EEF0F8").cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    // MARK: - 루틴 선택
    private let routineTitleLabel = UILabel().then {
        $0.text = "루틴 설정"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = UIColor(hex: "24252E")
    }
    
    private let routineExplanationLabel = UILabel().then {
        $0.text = "일주일에 몇일 반복하는지 선택해 주세요."
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.textColor = UIColor(hex: "6E707B")
    }
    
    private lazy var toggleButton = UISwitch().then {
        $0.isOn = false
        $0.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
    }
    
    private let routineRepeatList: [String] = [
        "월", "화", "수", "목","금",
        "토", "일"
    ]
    
    private let routineRepeatCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8 // 상하간격
        layout.minimumInteritemSpacing = 8 // 좌우간격
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        $0.isScrollEnabled = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.register(Reusable.repeatCell)
    }
    
    // 종료 달력
    
    private let endExplanationLabel = UILabel().then {
        $0.text = "언제까지 반복할까요?"
        $0.font = UIFont.pretendard(.regular, size: 14)
        $0.textColor = UIColor(hex: "6E707B")
        $0.isHidden = true
    }
    
    private let endLabel = UILabel().then {
        $0.text = "종료"
        $0.textColor = UIColor(hex: "000000")
        $0.font = UIFont.pretendard(.semiBold, size: 14)
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
        //calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        calendar.register(DatePickerCalendarCell.self, forCellReuseIdentifier: "cell")
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.configureView()
        self.configureNavBar()
        self.configureCategory()
        self.configureJogakDetailTitle()
        self.configureRoutine()
//        self.configureMogakTop()
//        self.configureCategory()
//        self.configureRepeat()
//        self.configureDate()
        self.configureEndDate()
//        self.configureColorCollectionView()
//
//        let today = startCalendar.today!
//        self.headerTitle.text = setYearAndMonth(of: today)
//        self.endHeaderTitle.text = setYearAndMonth(of: today)
//
        self.configureCompleteButton()
        
        endCalendar.allowsMultipleSelection = true
        endCalendar.scrollDirection = .vertical
        endCalendar.today = nil
        endCalendar.swipeToChooseGesture.isEnabled = true
        endCalendar.clipsToBounds = true
    }
    
    // MARK: - configure UI
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
        
        self.title = "조각 생성"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.pretendard(.semiBold, size: 18)]
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "chevron.left")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "24252E")
    }
    
    private func configureCategory() {
        [mogakCategoryTitleLabel, mogakCategoryView].forEach(contentView.addSubview(_:))
        
        mogakCategoryTitleLabel.snp.makeConstraints({
            $0.top.equalTo(self.contentView.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
        })
        
        mogakCategoryView.snp.makeConstraints({
            $0.top.equalTo(self.mogakCategoryTitleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(30)
            $0.width.equalTo(57)
        })
        
        mogakCategoryView.addSubview(mogakCategoryLabel)
        
        mogakCategoryLabel.snp.makeConstraints({
            $0.centerX.centerY.equalToSuperview()
        })
    }
    
    private func configureJogakDetailTitle() {
        [jogakDetailTitleLabel, jogakDetailTextField, jogakDetailUnderLineView].forEach(contentView.addSubview(_:))
        //self.jogakDetailTextField.delegate = self
        
        jogakDetailTitleLabel.snp.makeConstraints({
            $0.top.equalTo(mogakCategoryView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        jogakDetailTextField.snp.makeConstraints({
            $0.top.equalTo(jogakDetailTitleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        })
        
        jogakDetailUnderLineView.snp.makeConstraints({
            $0.top.equalTo(jogakDetailTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        })
    }
    
    private func configureRoutine() {
        [routineTitleLabel, routineExplanationLabel, routineRepeatCollectionView, toggleButton].forEach(contentView.addSubview(_:))
        
        self.routineRepeatCollectionView.delegate = self
        self.routineRepeatCollectionView.dataSource = self
        
        routineRepeatCollectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeightConstraint = routineRepeatCollectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint.isActive = true
        
        routineTitleLabel.snp.makeConstraints({
            $0.top.equalTo(jogakDetailUnderLineView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        })
        
        toggleButton.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(self.routineTitleLabel.snp.centerY)
            $0.width.equalTo(60)
            $0.height.equalTo(26)
        })
        
        routineExplanationLabel.snp.makeConstraints({
            $0.top.equalTo(self.routineTitleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        })
        
        routineRepeatCollectionView.snp.makeConstraints({
            $0.top.equalTo(self.routineExplanationLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-80)
            $0.height.equalTo(116)
        })
    }
    
    private func configureEndDate() {
        [endLabel, endExplanationLabel,  endTextField].forEach(contentView.addSubview(_:))
        [endHeaderTitle, endPreviousButton, endNextButton, endCalendar].forEach(contentView.addSubview(_:))
        self.endTextField.delegate = self
        self.endCalendar.delegate = self
        
        endExplanationLabel.snp.makeConstraints({
            $0.top.equalTo(self.routineRepeatCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        })
        
        endLabel.snp.makeConstraints({
            $0.top.equalTo(self.endExplanationLabel.snp.bottom).offset(26)
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
            //$0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview().offset(-60)
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
            $0.bottom.equalToSuperview().offset(-15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
//            $0.top.equalTo(endCalendar.snp.bottom).offset(50)
//            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.height.equalTo(50)
        })
    }
    
    // MARK: - objc
    @objc private func toggleSwitchChanged(_ sender: UISwitch) {
        routineRepeatCollectionView.isHidden = !sender.isOn
        endExplanationLabel.isHidden = !sender.isOn
        endTextField.isHidden = !sender.isOn
        endLabel.isHidden = !sender.isOn
        
        if !sender.isOn {
            [endNextButton, endHeaderTitle, endPreviousButton, endCalendar].forEach({$0.isHidden = true})
            
            endPreviousButton.snp.remakeConstraints({
                $0.top.equalTo(self.endLabel.snp.bottom).offset(43)
                $0.centerX.equalToSuperview().offset(-60)
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
            
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.collectionViewHeightConstraint.constant = sender.isOn ? 110 : 0
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
    
    @objc private func completeButtonTapped() {
        
    }
    
}

extension JogakInitViewController: UITextFieldDelegate {
    // 리턴 키 입력 시 키보드 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // 키보드 안 올라오게
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == jogakDetailTextField {
            return true
        }
        else if textField == endTextField { // 종료날짜
            [endNextButton, endHeaderTitle, endPreviousButton, endCalendar].forEach({$0.isHidden = false})
            //Get the size of the text to be displayed in the endLabel
            let text = endLabel.text ?? ""
            let textSize = (text as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: endLabel.bounds.height),
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [NSAttributedString.Key.font: endLabel.font!],
                                                           context: nil).size
            
//            contentView.snp.remakeConstraints({
//                $0.bottom.equalTo(completeButton.snp.bottom).offset(30)
//                $0.width.equalToSuperview().multipliedBy(1.0)
//            })
            completeButton.snp.remakeConstraints({
                $0.top.equalTo(endCalendar.snp.bottom).offset(50)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(50)
                $0.bottom.equalToSuperview().offset(-15)
            })
            self.view.layoutIfNeeded()
        }
        return false
    }
}

extension JogakInitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routineRepeatList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(Reusable.repeatCell, for: indexPath)
        cell.textLabel.text = routineRepeatList[indexPath.item]
        return cell
    }
}

extension JogakInitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    }
}

extension JogakInitViewController: UICollectionViewDelegateFlowLayout {
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel().then {
            $0.font = UIFont.pretendard(.medium, size: 16)
            $0.text = routineRepeatList[indexPath.item]
            $0.sizeToFit()
        }
        let size = label.frame.size
        
        return CGSize(width: size.width + 37, height: size.height + 32)
    }
}

// MARK: - 캘린더 관련
extension JogakInitViewController {
    private func setYearAndMonth(of date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    private func datesRange(from startDate: Date, to endDate: Date) -> [Date] {
        // 여기에 startDate부터 endDate까지의 날짜 배열을 생성하는 로직을 추가하세요.
        // 예를 들어, DateComponents를 사용하여 날짜 간격을 계산하고 배열을 만들 수 있습니다.
        var dates: [Date] = []
        
        var currentDate = startDate
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return dates
    }
}

extension JogakInitViewController: FSCalendarDelegate, FSCalendarDataSource {
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy/M/d(EEE)"
//        let selectedDateStr = dateFormatter.string(from: date)
//        print("종료 Selected Date: \(selectedDateStr)")
//        endTextField.text = selectedDateStr
//    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // nothing selected:
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            
            print("datesRange contains: \(datesRange!)")
            
            return
        }
        
        // only first date is selected:
        if firstDate != nil && lastDate == nil {
            // handle the case of if the last date is less than the first date:
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                
                print("datesRange contains: \(datesRange!)")
                
                return
            }
            
            let range = datesRange(from: firstDate!, to: date)

            lastDate = range.last
            
            for d in range {
                calendar.select(d)
            }
            
            datesRange = range
            
            print("datesRange contains: \(datesRange!)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/M/d(EEE)"
            let selectedDateStr = dateFormatter.string(from: lastDate!)
            print("종료 Selected Date: \(selectedDateStr)")
            endTextField.text = selectedDateStr
            return
        }
        
        // both are selected:
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            
            lastDate = nil
            firstDate = nil
            
            datesRange = []
            
            print("datesRange contains: \(datesRange!)")
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let date = calendar.currentPage
        let formatter = DateFormatter()
        // 년과 월을 출력하기 위한 포맷 설정
        formatter.dateFormat = "yyyy년 M월"
        let dateString = formatter.string(from: date)
        
        self.endHeaderTitle.text = dateString
    }
}

@available(iOS 17.0, *)
#Preview("JogakInitVC") {
    JogakInitViewController()
}
