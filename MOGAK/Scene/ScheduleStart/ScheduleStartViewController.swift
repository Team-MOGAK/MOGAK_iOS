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
    
    private lazy var profileImageView : UIButton = {
        let profileImageView = UIButton()
        profileImageView.setImage(UIImage(named: "default"), for: .normal)
        profileImageView.layer.cornerRadius = 18
        profileImageView.clipsToBounds = true
        profileImageView.addTarget(self, action: #selector(goSetting), for: .touchUpInside)
        return profileImageView
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
        challengeLabel.text = "우리가 도전한지 벌써 127일째!"
        challengeLabel.font = UIFont(name: "Pretendard", size: 12)
        challengeLabel.textColor = UIColor(hex: "#6E707B")
        return challengeLabel
    }()
    
    private lazy var alarmButton : UIButton = {
        let alarmButton = UIButton()
        alarmButton.backgroundColor = .clear
        alarmButton.setImage(UIImage(named: "noalarm"), for: .normal)
        alarmButton.layer.cornerRadius = 12
        alarmButton.addTarget(self, action: #selector(goAlarm), for: .touchUpInside)
        return alarmButton
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
        //toggleButton.semanticContentAttribute = .forceRightToLeft
        toggleButton.addTarget(self, action: #selector(tapToggleButton), for: .touchUpInside)
        return toggleButton
    }()
    
    private lazy var leftButton : UIButton = {
        let leftButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.setImage(UIImage(named: "<"), for: .normal)
        leftButton.addTarget(self, action: #selector(tapBeforeWeek), for: .touchUpInside)
        return leftButton
    }()
    
    private lazy var rightButton : UIButton = {
        let rightButton = UIButton()
        rightButton.backgroundColor = .clear
        rightButton.setImage(UIImage(named: ">"), for: .normal)
        rightButton.addTarget(self, action: #selector(tapNextWeek), for: .touchUpInside)
        return rightButton
    }()
    
    private lazy var headerLabel = UILabel().then { [weak self] in
        guard let self = self else { return }
        $0.font = UIFont(name: "Pretendard", size: 18)
        $0.textColor = .label
        $0.text = self.headerDataFormatter.string(from: Date())
        $0.textAlignment = .center
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
    
    private lazy var blankimage : UIImageView = {
        let blankimage = UIImageView()
        blankimage.image = UIImage(named: "blankImage")
        blankimage.clipsToBounds = true
        return blankimage
    }()
    
    private lazy var blankLabel : UILabel = {
        let blankLabel = UILabel()
        blankLabel.text = "내 조각이 없어요...\n더 나은 내일을 위해 조각을 시작해볼까요?"
        blankLabel.font = UIFont(name: "Pretendard", size: 16)
        blankLabel.textColor = UIColor(hex: "#808497")
        blankLabel.numberOfLines = 2
        blankLabel.textAlignment = .center
        return blankLabel
    }()
    
    
    private lazy var blankButton : UIButton = {
        let blankbutton = UIButton()
        blankbutton.backgroundColor = .clear
        blankbutton.setImage(UIImage(named: "blankButton"), for: .normal)
        blankbutton.layer.cornerRadius = 15 //둥글기
        blankbutton.addTarget(self, action: #selector(goSchedule), for: .touchUpInside)
        return blankbutton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(hex: "F1F3FA")
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
            $0.distribution = .fill
            $0.spacing = 0
        }
        
        let profileStackView = UIStackView(arrangedSubviews: [profileImageView,LabelStackView]).then{
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.spacing = 8
            profileImageView.snp.makeConstraints{
                $0.height.width.equalTo(36.0)
            }
        }
        
        let blankStackView = UIStackView(arrangedSubviews: [blankimage,blankLabel,blankButton]).then{
            $0.axis = .vertical
            $0.distribution = .fill
            //$0.distribution = .equalCentering
            $0.alignment = .center
            //$0.spacing = 10
            
            blankimage.snp.makeConstraints{
                $0.width.height.equalTo(88.0)
            }
            blankButton.snp.makeConstraints{
                $0.width.equalTo(129)
                $0.height.equalTo(30)
            }
        }
        
        let headerStackView = UIStackView(arrangedSubviews: [leftButton,headerLabel,rightButton]).then{
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            
            headerLabel.snp.makeConstraints{
                $0.height.equalTo(28.0)
                $0.width.equalTo(110)
                
            }
        }
        
        
        [upperView,profileStackView,alarmButton,calendarView,headerStackView,toggleButton,motiveLabel,blankStackView].forEach{view.addSubview($0)}
        
        
        profileStackView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.equalTo(calendarView.collectionView)
            $0.bottom.equalTo(headerStackView.snp.top).offset(-25)
        }
        alarmButton.snp.makeConstraints{
            $0.top.equalTo(nameLabel.snp.top)
            $0.trailing.equalTo(calendarView.collectionView)
            $0.width.height.equalTo(24)
        }
        
        blankStackView.snp.makeConstraints{
            $0.top.equalTo(calendarView.snp.bottom).offset(130)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(263)
            $0.height.equalTo(190)
            
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
        
        let offset: Double = (self.view.frame.width - ("YYYY년 M월"as NSString)
            .size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)])
            .width - 16.0 ) / 2.0
        
        calendarView.appearance.headerTitleOffset = CGPoint(x: -offset, y: 0)
        
        calendarView.weekdayHeight = 40
        calendarView.headerHeight = 60
        
        calendarView.appearance.weekdayFont = UIFont(name: "Pretendard", size: 12)
        calendarView.appearance.titleDefaultColor = UIColor(hex: "#200E04")
        calendarView.appearance.titleFont = UIFont(name: "Pretendard", size: 16)
        calendarView.appearance.titleTodayColor = UIColor(hex: "#200E04")
        calendarView.appearance.todayColor = .white
        calendarView.appearance.weekdayTextColor = UIColor(hex: "#808080")
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
    
    @objc func goSetting(_ sender : UIButton){
        print("go setting")
    }
    
    @objc func goSchedule(_ sender : UIButton){
        print("go Schedule")
    }
    
    @objc func goAlarm(_ sender : UIButton){
        print("go alarm")
    }
    
    @objc func tapNextWeek(_ sender : UIButton){
        self.calendarView.setCurrentPage(getNextWeek(date: calendarView.currentPage), animated: true)
        print("TapNextWeek")
    }
    
    @objc func tapBeforeWeek(_ sender : UIButton){
        self.calendarView.setCurrentPage(getProviousWeek(date: calendarView.currentPage), animated: true)
        print("TapBeforeWeek")
    }
    
}

