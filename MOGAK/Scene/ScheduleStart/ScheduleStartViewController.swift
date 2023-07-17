//
//  ViewController.swift
//  MOGAK
//
//  Created by 김강현 on 2023/06/23.
//

import UIKit
import SnapKit
import FSCalendar
import Then

class ScheduleStartViewController: UIViewController ,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    
    private lazy var imageView : UIImageView = {
       let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel : UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "이름"
        nameLabel.font = UIFont(name: "Pretendard", size: 14)
        nameLabel.textColor = UIColor(hex: "#200E04")
        return nameLabel
    }()

    private lazy var challengeLabel : UILabel = {
        let challengeLabel = UILabel()
        challengeLabel.text = "우리가 도전한지 벌써 일째!"
        challengeLabel.font = UIFont(name: "Pretendard", size: 12)
        challengeLabel.textColor = UIColor(hex: "#6E707B")
        return challengeLabel
    }()
    
    private lazy var calendarView : FSCalendar = {
        let calendarView = FSCalendar(frame: .zero)
        return calendarView
    }()
    
    private lazy var headerDataFormatter = DateFormatter().then {
        $0.dateFormat = "YYYY년 MM월"
        $0.locale = Locale(identifier : "ko_kr")
        $0.timeZone = TimeZone(identifier : "KST")
    }
    
    
    private lazy var toggleButton : UIButton = { //기본값
        let toggleButton = UIButton()
        toggleButton.setImage(UIImage(named: "week"), for: .normal)
        toggleButton.backgroundColor = .clear //백그라운드색
        toggleButton.layer.cornerRadius = 8 //둥글기
        toggleButton.semanticContentAttribute = .forceRightToLeft
        //toggleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12.0, bottom: 0, right: 0)
        toggleButton.addTarget(self, action: #selector(tapToggleButton), for: .touchUpInside)
        return toggleButton
    }()
    
    private lazy var leftButton : UIButton = {
        let leftButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.setTitle("<", for: .normal)
        leftButton.setTitleColor(.black, for: .normal)
        leftButton.addTarget(self, action: #selector(tapBeforeWeek), for: .touchUpInside)
        return leftButton
    }()
    
    private lazy var rightButton : UIButton = {
        let rightButton = UIButton()
        rightButton.backgroundColor = .clear
        rightButton.setTitle(">", for: .normal)
        rightButton.setTitleColor(.black, for: .normal)
        rightButton.addTarget(self, action: #selector(tapNextWeek), for: .touchUpInside)
        return rightButton
    }()
    
    private lazy var headerLabel = UILabel().then { [weak self] in
        guard let self = self else { return }
        $0.font = UIFont(name: "Pretendard", size: 18)
        $0.textColor = .label
        $0.text = self.headerDataFormatter.string(from: Date())
    }
    
    
    private lazy var upperView : UIView = {
        let upperView = UIView()
        upperView.backgroundColor = .white
        return upperView
    }()
    
    private lazy var motiveLabel : UILabel = {
        let motiveLabel = UILabel()
        motiveLabel.text = "오늘도 조금씩 더 나은 내일을 위해, 조각을 시작해 볼까요?"
        motiveLabel.textColor = UIColor(hex: "#6E707B")
        motiveLabel.font = UIFont(name: "Pretendard", size: 14)
        return motiveLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "F1F3FA")
        view.addSubview(upperView)
        self.configureUI()
        self.configureCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarView.snp.updateConstraints{make in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentPage = calendar.currentPage
        headerLabel.text = headerDataFormatter.string(from: currentPage)
    }
    
    private func configureUI(){
        
        let LabelStackView = UIStackView(arrangedSubviews:[nameLabel,challengeLabel]).then{
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.spacing = 3
        }
        
        let headerStackView = UIStackView(arrangedSubviews: [leftButton,headerLabel,rightButton]).then{
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            //$0.spacing = 3
            
            headerLabel.snp.makeConstraints{
                $0.height.equalTo(28.0)
                $0.width.equalTo(110)
            }
        }
        let profileStackView = UIStackView(arrangedSubviews: [imageView,LabelStackView]).then{
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.spacing = 3
        }
        
        [profileStackView,calendarView,headerStackView,toggleButton,motiveLabel].forEach{view.addSubview($0)}
        
        profileStackView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(calendarView.collectionView)
        }
        headerStackView.snp.makeConstraints{
            $0.centerY.equalTo(calendarView.calendarHeaderView.snp.centerY)
            $0.leading.equalTo(calendarView.collectionView)
        }
        calendarView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32) //달력 대가리
            $0.trailing.leading.equalToSuperview().inset(12)
            $0.height.equalTo(300)
        }
        toggleButton.snp.makeConstraints{
            $0.centerY.equalTo(calendarView.calendarHeaderView.snp.centerY)
            $0.trailing.equalTo(calendarView.collectionView)
            $0.height.equalTo(28)
            $0.width.equalTo(68)
        }
        upperView.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(calendarView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        motiveLabel.snp.makeConstraints{
            $0.top.equalTo(calendarView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
    }
    
    private func configureCalendar(){
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.select(Date())
        
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.scope = .week
        
        calendarView.appearance.headerTitleColor = .clear
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        
        calendarView.appearance.selectionColor = UIColor(hex: "#475FFD")
        
        let offset: Double = (self.view.frame.width - ("YYYY년 MM월" as NSString)
            .size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)])
            .width - 16.0 ) / 2.0
        
        calendarView.appearance.headerTitleOffset = CGPoint(x: -offset, y: 0)
        
        calendarView.weekdayHeight = 36
        calendarView.headerHeight = 36
        
        calendarView.appearance.weekdayFont = .systemFont(ofSize: 14.0)
        calendarView.appearance.titleDefaultColor = .secondaryLabel
        
        calendarView.appearance.todayColor = .clear
        calendarView.appearance.weekdayTextColor = .label
        
        calendarView.placeholderType = .none
        
        calendarView.scrollEnabled = true
        calendarView.scrollDirection = .horizontal
    }
    
    func getNextWeek(date : Date) -> Date {
        return Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: date)!
    }
    
    func getProviousWeek(date : Date) -> Date {
        return Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: date)!
    }
    
    @objc func tapToggleButton(){
        if self.calendarView.scope == .month {
            self.calendarView.setScope(.week, animated: true)
            
            self.headerDataFormatter.dateFormat = "YYYY년 MM월"
            self.toggleButton.setImage(UIImage(named: "week"), for: .normal)
            self.headerLabel.text = headerDataFormatter.string(from: calendarView.currentPage)
        }else{
            self.calendarView.setScope(.month, animated: true)
            self.headerDataFormatter.dateFormat = "YYYY년 MM월"
            self.toggleButton.setImage(UIImage(named: "month"), for: .normal)
            self.headerLabel.text = headerDataFormatter.string(from: calendarView.currentPage)
        }
    }
    
    @objc func tapNextWeek(){
        self.calendarView.setCurrentPage(getNextWeek(date: calendarView.currentPage), animated: true)
        print("TapNextWeek")
    }
    @objc func tapBeforeWeek(){
        self.calendarView.setCurrentPage(getProviousWeek(date: calendarView.currentPage), animated: true)
        print("TapBeforeWeek")
    }
    
}

